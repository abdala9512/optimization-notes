import numpy as np
import random

class GRASPKnapsack:
    
    
    def __init__(self, utility: list, weight: list, capacity, max_iter, seed, alpha = 0.5):
        
        if len(utility) != len(weight):
            raise Exception('Listas de utilidad y pesos deben tener la misma longitud')

        self.utility       = utility
        self.weight        = weight
        self.max_iter      = max_iter
        self.seed          = seed
        self.alpha         = alpha
        self.capacity      = capacity
        self.n_objects     = len(utility)
        self.knapsack_ratio = [ u / p if p != 0 else u for u,p in zip(self.utility, self.weight) ]
    
    def greedy_randomized_construction(self):
        
        greedy_solution = np.zeros(self.n_objects, dtype = int)
        knapsack_instance = self.knapsack_ratio.copy()
        
        used_capacity = 0
        
        while used_capacity < self.capacity:
            
            rcl = self.calculate_rcl(knapsack_instance)
            greedy_solution, returned, taken_object = self.random_object(greedy_solution, rcl)
            
            if used_capacity + self.weight[taken_object] > self.capacity: 
                greedy_solution = returned
                break
            else:
                used_capacity+= self.weight[taken_object]
                knapsack_instance[taken_object] = np.nan
        
        print("Solucion obtenida----------------")
        print(greedy_solution)
        print("Peso usado: ", used_capacity)
        print("Total ganancia: ", sum(greedy_solution * self.utility) )
        
        return greedy_solution
            
            
    def local_search(self, solution):
        
        searched_solution = solution.copy()
        
        solution_gains   = [gain if gain != 0 else np.nan for gain in searched_solution * self.utility]
        solution_weights = [weight if weight != 0 else np.nan for weight in searched_solution * self.weight]
        ratios           = [ratio if ratio != 0 else np.nan for ratio in searched_solution * self.knapsack_ratio]
        
        #1.Quitar elemento de menor utilidad y cambiarlo por el de amyor utilidad que no este incluido
        
        operator1_solution = self.search_operator(
            to_drop = np.nanargmin(solution_gains),
            solution_gains = solution_gains,
            solution_weights = solution_weights,
            ratios = ratios,
            solution = searched_solution,
            criteria = self.utility
        )
        

        #2. Quitar el mas pesado  e incluir el de mayor utilidad no incluido
        
        operator2_solution = self.search_operator(
            to_drop =np.nanargmax(solution_weights),
            solution_gains = solution_gains,
            solution_weights = solution_weights,
            ratios = ratios,
            solution = operator1_solution,
            criteria = self.utility
        )


        #3.Quitar el de menor relacion  utilidad/peso  e incluir el de mayor relacion  utilidad/peso
        operator3_solution = self.search_operator(
            to_drop =np.nanargmax(ratios),
            solution_gains = solution_gains,
            solution_weights = solution_weights,
            ratios = ratios,
            solution = operator2_solution,
            criteria = self.knapsack_ratio
            
        )

        
        #4.Escoger aleatoriamente uno de los actuales y lo quitamos. Seleccionamos uno de los no incluidos aleatoriamente
        searched_solution, _, _ = self.random_object(operator3_solution, choices = [i for i, obj in enumerate(operator3_solution)  if obj == 1] ,case=0)
        local_solution, _, _ = self.random_object(operator3_solution, choices = [i for i, obj in enumerate(operator3_solution)  if obj == 0], validate_candidate = True)
        
        print("Solucion obtenida----------------")
        print(local_solution)
        print("Peso usado: ", sum(np.array(local_solution) * self.weight))
        print("Total ganancia: ", sum(np.array(local_solution) * self.utility) )
        
        return searched_solution, sum(np.array(local_solution) * self.utility)
    
    
    def search_operator(self, to_drop, solution_gains, solution_weights, ratios, solution, criteria):
        
        solution_gains[to_drop]   = np.nan
        solution_weights[to_drop] = np.nan
        ratios[to_drop]           = np.nan
        
        searched_solution = self.update_solution(solution, vector = solution_gains)
        
        to_take = self.check_current_capacity(searched_solution, candidates = self.select_candidates(searched_solution, criteria = criteria))
        
        solution_gains[to_take]   = self.utility[to_take]
        solution_weights[to_take] = self.weight[to_take]
        ratios[to_take]           = self.knapsack_ratio[to_take]
        
        
        return  self.update_solution(solution, vector = solution_gains)
        
    
    def update_solution(self, solution, vector):
         return [0 if np.isnan(obj) else 1 for obj in vector]
        
    # utils
    def calculate_rcl(self, arr):
        
        low_bound   = np.nanmin(arr)
        upper_bound = np.nanmax(arr)
            
        R = upper_bound - low_bound
        low_bound += (1 - self.alpha) * R 
            
        rcl = [i for i, obj in enumerate(arr) if low_bound <= obj <= upper_bound]
        
        return rcl
    
    def random_object(self, arr, choices: list, case = 1, validate_candidate=False):
        
        
        print("choices:  ----> ", choices)
        initial = arr.copy()
        
        if not choices:
            raise Exception("No hay RCL")
        random_pos = random.choice(choices)
        print(f"position selected: {random_pos}")
        if validate_candidate:
            current_capacity = sum(np.array(arr) * self.weight)
            valid_candidate = self.check_candidate(current_capacity, random_pos)
        else:
            valid_candidate = False
        
        if valid_candidate:
            choices.remove(random_pos)
            self.random_object(arr, choices, validate_candidate=True)
        elif arr[random_pos] != case: 
            arr[random_pos] = case
        else: 
            choices.remove(random_pos)
            self.random_object(arr, choices)
        
        return arr, initial, random_pos
    
    
    def select_candidates(self, arr, criteria: list):
        arr = np.array(arr)
        current_capacity = sum(np.array(arr) * self.weight)
        print("Peso actual: ", current_capacity)
        weights_ = [w * 1 if s == 0 else 0 for w,s in zip(criteria, arr)]
        outside_candidates = sorted(range(len(weights_)), key=lambda k: weights_[k],reverse=True)[:len(arr) - sum(arr)]
        
        return outside_candidates
    
    def check_current_capacity(self, arr, candidates):
        
        current_capacity = sum(np.array(arr) * self.weight)
        
        print("candidatos a elegir: ", len(candidates))
        for take in candidates:
            if current_capacity + self.weight[take] > self.capacity:
                next
            else:
                return take
    
    def check_candidate(self, current_capacity, candidate):
        return (current_capacity + self.weight[candidate]) > self.capacity
            
        
    def solve(self):
        random.seed(self.seed)
        best_solution = 0
        for i in range(self.max_iter):
            print("-------------------------------------------------------------------------")
            print(f"Iteracion {i+1}, Mejor solucion: ", best_solution)
            print("-------------------------------------------------------------------------")
            contruction_phase = self.greedy_randomized_construction()
            _, local_solution = self.local_search(contruction_phase)
            print(f"Local solucion: ", local_solution)
            if local_solution > best_solution:
                print("Nueva mejor solucion encontrada")
                best_solution = local_solution
        print("MEjor solucion: ", best_solution)    
        self.solution = best_solution
        return best_solution
