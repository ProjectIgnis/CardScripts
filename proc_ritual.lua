if not aux.RitualProcedure then
	aux.RitualProcedure = {}
	Ritual = aux.RitualProcedure
end
if not Ritual then
	Ritual = aux.RitualProcedure
end
function Ritual.GetMatchingFilterFunction(c)
	local mt=c.__index
	if not mt.ritual_matching_function or not mt.ritual_matching_function[c] then
		return aux.TRUE
	end
	return mt.ritual_matching_function[c]
end
function Ritual.CheckMatFilter(matfilter,e,tp,mg,mg2)
	if matfilter then
		if type(matfilter)=="function" then
			mg:Sub(mg:Filter(aux.NOT(matfilter),nil,e,tp))
			mg2:Sub(mg2:Filter(aux.NOT(matfilter),nil,e,tp))
		else
			local f=function(c)
						return not matfilter:IsContains(c)
					end
			mg:Sub(mg:Filter(f,nil))
			mg2:Sub(mg2:Filter(f,nil))
		end
	end
end
--The current total level to match for the monster being summoned, to be used with monsters that can be used as whole tribute
Ritual.SummoningLevel=nil
function Ritual.AddWholeLevelTribute(c,condition)
	local e=Effect.CreateEffect(c)
	e:SetType(EFFECT_TYPE_SINGLE)
	e:SetCode(EFFECT_RITUAL_LEVEL)
	e:SetValue(Ritual.WholeLevelTributeValue(condition))
	c:RegisterEffect(e)
	return e
end
function Ritual.WholeLevelTributeValue(cond)
	return function(e,c)
		local lv=e:GetHandler():GetLevel()
		if cond(c,e) then
			local clv=Ritual.SummoningLevel or c:GetLevel()
			return (lv<<16)|clv
		else return lv end
	end
end
--Ritual Summon
Ritual.CreateProc = aux.FunctionWithNamedArgs(
function(c,_type,filter,lv,desc,extrafil,extraop,matfilter,stage2,location,forcedselection,customoperation,specificmatfilter,requirementfunc,sumpos,extratg)
	--lv can be a function (like GetLevel/GetOriginalLevel), fixed level, if nil it defaults to GetLevel
	if filter and type(filter)=="function" then
		local mt=c.__index
		if not mt.ritual_matching_function then
			mt.ritual_matching_function={}
		end
		mt.ritual_matching_function[c]=filter
	end
	local e1=Effect.CreateEffect(c)
	if desc then
		e1:SetDescription(desc)
	else
		e1:SetDescription(1171)
	end
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(Ritual.Target(filter,_type,lv,extrafil,extraop,matfilter,stage2,location,forcedselection,specificmatfilter,requirementfunc,sumpos,extratg))
	e1:SetOperation(Ritual.Operation(filter,_type,lv,extrafil,extraop,matfilter,stage2,location,forcedselection,customoperation,specificmatfilter,requirementfunc,sumpos))
	return e1
end,"handler","lvtype","filter","lv","desc","extrafil","extraop","matfilter","stage2","location","forcedselection","customoperation","specificmatfilter","requirementfunc","sumpos","extratg")

Ritual.AddProc = aux.FunctionWithNamedArgs(
function(c,_type,filter,lv,desc,extrafil,extraop,matfilter,stage2,location,forcedselection,customoperation,specificmatfilter,requirementfunc,sumpos,extratg)
	local e1=Ritual.CreateProc(c,_type,filter,lv,desc,extrafil,extraop,matfilter,stage2,location,forcedselection,customoperation,specificmatfilter,requirementfunc,sumpos,extratg)
	c:RegisterEffect(e1)
	return e1
end,"handler","lvtype","filter","lv","desc","extrafil","extraop","matfilter","stage2","location","forcedselection","customoperation","specificmatfilter","requirementfunc","sumpos","extratg")

local function WrapTableReturn(func)
	if func then
		return function(...)
			return {func(...)}
		end
	end
end
local function MergeForcedSelection(f1,f2)
	if f1==nil or f2==nil then
		return f1 or f2
	end
	return function(...)
		local ret1,ret2=f1(...)
		local repl1,repl2=f2(...)
		return ret1 and repl1,ret2 or repl2
	end
end
function Ritual.Filter(c,filter,_type,e,tp,m,m2,forcedselection,specificmatfilter,lv,requirementfunc,sumpos)
	if not (c:IsOriginalType(TYPE_RITUAL) and c:IsOriginalType(TYPE_MONSTER)) or (filter and not filter(c)) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true,sumpos) then return false end
	local lv=(lv and (type(lv)=="function" and lv(c)) or lv) or c:GetLevel()
	lv=math.max(1,lv)
	Ritual.SummoningLevel=lv
	local mg=m:Filter(Card.IsCanBeRitualMaterial,c,c)
	mg:Merge(m2-c)
	if c.ritual_custom_condition then
		return c:ritual_custom_condition(mg,forcedselection,_type)
	end
	if c.mat_filter then
		mg:Match(c.mat_filter,c,tp)
	end
	if specificmatfilter then
		mg:Match(specificmatfilter,nil,c,mg,tp)
	end
	forcedselection=MergeForcedSelection(c.ritual_custom_check,forcedselection)
	local res=aux.SelectUnselectGroup(mg,e,tp,1,lv,Ritual.Check(c,lv,WrapTableReturn(forcedselection),_type,requirementfunc),0)
	Ritual.SummoningLevel=nil
	return res
end
local function ExtraReleaseFilter(c,tp)
	return c:IsControler(1-tp) and c:IsHasEffect(EFFECT_EXTRA_RELEASE)
end
local function ForceExtraRelease(mg)
	return function(e,tp,g,c)
		return g:Includes(mg)
	end
end
local function GetDefaultSummonFromLocation()
	return Duel.IsDuelType(DUEL_EXTRA_DECK_RITUAL) and LOCATION_EXTRA or LOCATION_HAND
end
Ritual.Target = aux.FunctionWithNamedArgs(
function(filter,_type,lv,extrafil,extraop,matfilter,stage2,location,forcedselection,specificmatfilter,requirementfunc,sumpos,extratg)
	location = location or GetDefaultSummonFromLocation()
	sumpos = sumpos or POS_FACEUP
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then
					local mg=Duel.GetRitualMaterial(tp,not requirementfunc)
					local mg2=extrafil and extrafil(e,tp,eg,ep,ev,re,r,rp,chk) or Group.CreateGroup()
					--if an EFFECT_EXTRA_RITUAL_MATERIAL effect has a forcedselection of its own
					--add that forcedselection to the one of the Ritual Spell, if any
					local extra_eff_g=mg:Filter(Card.IsHasEffect,nil,EFFECT_EXTRA_RITUAL_MATERIAL)
					local func=forcedselection
					--if a card controlled by the opponent has EFFECT_EXTRA_RELEASE, then it MUST be
					--used as material
					local extra_mat_g=mg:Filter(ExtraReleaseFilter,nil,tp)
					if #extra_mat_g>0 then
						func=MergeForcedSelection(ForceExtraRelease(extra_mat_g),func)
					end
					if #extra_eff_g>0 then
						local prev_repl_function=nil
						for tmp_c in extra_eff_g:Iter() do
							local effs={tmp_c:IsHasEffect(EFFECT_EXTRA_RITUAL_MATERIAL)}
							for _,eff in ipairs(effs) do
								local repl_function=eff:GetLabelObject()
								if repl_function and prev_repl_function~=repl_function[1] then
									prev_repl_function=repl_function[1]
									func=MergeForcedSelection(func,repl_function[1])
								end
							end
						end
					end
					Ritual.CheckMatFilter(matfilter,e,tp,mg,mg2)
					return Duel.IsExistingMatchingCard(Ritual.Filter,tp,location,0,1,nil,filter,_type,e,tp,mg,mg2,func,specificmatfilter,lv,requirementfunc,sumpos)
				end
				if extratg then extratg(e,tp,eg,ep,ev,re,r,rp,chk) end
				Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,location)
			end
end,"filter","lvtype","lv","extrafil","extraop","matfilter","stage2","location","forcedselection","specificmatfilter","requirementfunc","sumpos","extratg")

function Auxiliary.RitualCheckAdditionalLevel(c,rc)
	local raw_level=c:GetRitualLevel(rc)
	local lv1=raw_level&0xffff
	local lv2=raw_level>>16
	if lv2>0 then
		return math.min(lv1,lv2)
	else
		return lv1
	end
end
function Ritual.Check(sc,lv,forcedselection,_type,requirementfunc)
	local chk
	if _type==RITPROC_EQUAL then
		chk=function(g) return g:GetSum(requirementfunc or Auxiliary.RitualCheckAdditionalLevel,sc)<=lv end
	else
		chk=function(g,c) return g:GetSum(requirementfunc or Auxiliary.RitualCheckAdditionalLevel,sc) - (requirementfunc or Auxiliary.RitualCheckAdditionalLevel)(c,sc)<=lv end
	end
	return function(sg,e,tp,mg,c)
		local res=chk(sg,c)
		if not res then return false,true end
		local stop=false
		if forcedselection then
			local ret=forcedselection(e,tp,sg,sc)
			res=ret[1]
			stop=ret[2] or stop
		end
		if res and not stop then
			if _type==RITPROC_EQUAL then
				res=sg:CheckWithSumEqual(requirementfunc or Card.GetRitualLevel,lv,#sg,#sg,sc)
			else
				Duel.SetSelectedCard(sg)
				res=sg:CheckWithSumGreater(requirementfunc or Card.GetRitualLevel,lv,sc)
			end
			local stop=false
			res=res and (sc:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,sg,sc) or Duel.GetMZoneCount(tp,sg,tp))>0
		end
		return res,stop
	end
end
function Ritual.Finishcon(sc,lv,forcedselection,requirementfunc,_type)
	return function(sg,e,tp,mg)
		if forcedselection then
			local ret=forcedselection(e,tp,sg,sc)
			if not ret[1] then return false end
		end
		if _type==RITPROC_EQUAL then
			return sg:CheckWithSumEqual(requirementfunc or Card.GetRitualLevel,lv,#sg,#sg,sc)
		else
			Duel.SetSelectedCard(sg)
			return sg:CheckWithSumGreater(requirementfunc or Card.GetRitualLevel,lv,sc)
		end
	end
end

Ritual.Operation = aux.FunctionWithNamedArgs(
function(filter,_type,lv,extrafil,extraop,matfilter,stage2,location,forcedselection,customoperation,specificmatfilter,requirementfunc,sumpos)
	location = location or GetDefaultSummonFromLocation()
	sumpos = sumpos or POS_FACEUP
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local mg=Duel.GetRitualMaterial(tp,not requirementfunc)
				local mg2=extrafil and extrafil(e,tp,eg,ep,ev,re,r,rp) or Group.CreateGroup()
				--if an EFFECT_EXTRA_RITUAL_MATERIAL effect has a forcedselection of its own
				--add that forcedselection to the one of the Ritual Spell, if any
				local func=forcedselection
				local extra_eff_g=mg:Filter(Card.IsHasEffect,nil,EFFECT_EXTRA_RITUAL_MATERIAL)
				if #extra_eff_g>0 then
					local prev_repl_function=nil
					for tmp_c in extra_eff_g:Iter() do
						local effs={tmp_c:IsHasEffect(EFFECT_EXTRA_RITUAL_MATERIAL)}
						for _,eff in ipairs(effs) do
							local repl_function=eff:GetLabelObject()
							if repl_function and prev_repl_function~=repl_function[1] then
								prev_repl_function=repl_function[1]
								func=MergeForcedSelection(func,repl_function[1])
							end
						end
					end
				end
				--if a card controlled by the opponent has EFFECT_EXTRA_RELEASE, then it MUST be
				--used as material
				local extra_mat_g=mg:Filter(ExtraReleaseFilter,nil,tp)
				if #extra_mat_g>0 then
					func=MergeForcedSelection(ForceExtraRelease(extra_mat_g),func)
				end
				Ritual.CheckMatFilter(matfilter,e,tp,mg,mg2)
				local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Ritual.Filter),tp,location,0,1,1,nil,filter,_type,e,tp,mg,mg2,func,specificmatfilter,lv,requirementfunc,sumpos)
				if #tg>0 then
					local tc=tg:GetFirst()
					local lv=(lv and (type(lv)=="function" and lv(tc)) or lv) or tc:GetLevel()
					lv=math.max(1,lv)
					Ritual.SummoningLevel=lv
					local mat=nil
					mg:Match(Card.IsCanBeRitualMaterial,tc,tc)
					mg:Merge(mg2-tc)
					if specificmatfilter then
						mg:Match(specificmatfilter,nil,tc,mg,tp)
					end
					if tc.ritual_custom_operation then
						tc:ritual_custom_operation(mg,func,_type)
						mat=tc:GetMaterial()
					else
						func=MergeForcedSelection(tc.ritual_custom_check,func)
						if tc.mat_filter then
							mg:Match(tc.mat_filter,tc,tp)
						end
						if ft>0 and not func then
							Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
							if _type==RITPROC_EQUAL then
								mat=mg:SelectWithSumEqual(tp,requirementfunc or Card.GetRitualLevel,lv,1,#mg,tc)
							else
								mat=mg:SelectWithSumGreater(tp,requirementfunc or Card.GetRitualLevel,lv,tc)
							end
						else
							mat=aux.SelectUnselectGroup(mg,e,tp,1,lv,Ritual.Check(tc,lv,WrapTableReturn(func),_type,requirementfunc),1,tp,HINTMSG_RELEASE,Ritual.Finishcon(tc,lv,WrapTableReturn(func),requirementfunc,_type))
						end
					end
					--check if a card from an "once per turn" EFFECT_EXTRA_RITUAL_MATERIAL effect was selected
					local extra_eff_g=mat:Filter(Card.IsHasEffect,nil,EFFECT_EXTRA_RITUAL_MATERIAL)
					for tmp_c in extra_eff_g:Iter() do
						local effs={tmp_c:IsHasEffect(EFFECT_EXTRA_RITUAL_MATERIAL)}
						for _,eff in ipairs(effs) do
							--if eff is OPT and tmp_c is not returned
							--by the Ritual Spell's exrafil
							--then use the count limit and register
							--the flag to turn the extra eff OFF
							--requires the EFFECT_EXTRA_RITUAL_MATERIAL effect
							--to check the flag in its condition
							local _,max_count_limit=eff:GetCountLimit()
							if max_count_limit>0 and not mg2:IsContains(tmp_c) then
								eff:UseCountLimit(tp,1)
								Duel.RegisterFlagEffect(tp,eff:GetHandler():GetCode(),RESET_PHASE+PHASE_END,0,1)
							end
						end
					end
					if not customoperation then
						tc:SetMaterial(mat)
						if extraop then
							extraop(mat:Clone(),e,tp,eg,ep,ev,re,r,rp,tc)
						else
							Duel.ReleaseRitualMaterial(mat)
						end
						Duel.BreakEffect()
						Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,sumpos)
						tc:CompleteProcedure()
						if tc:IsFacedown() then Duel.ConfirmCards(1-tp,tc) end
						if stage2 then
							stage2(mat,e,tp,eg,ep,ev,re,r,rp,tc)
						end
					else
						customoperation(mat:Clone(),e,tp,eg,ep,ev,re,r,rp,tc)
					end
					Ritual.SummoningLevel=nil
				end
			end
end,"filter","lvtype","lv","extrafil","extraop","matfilter","stage2","location","forcedselection","customoperation","specificmatfilter","requirementfunc","sumpos")

--Ritual Summon, geq fixed lv
Ritual.AddProcGreater = aux.FunctionWithNamedArgs(
function(c,filter,lv,desc,extrafil,extraop,matfilter,stage2,location,forcedselection,customoperation,specificmatfilter,requirementfunc,sumpos,extratg)
	return Ritual.AddProc(c,RITPROC_GREATER,filter,lv,desc,extrafil,extraop,matfilter,stage2,location,forcedselection,customoperation,specificmatfilter,requirementfunc,sumpos,extratg)
end,"handler","filter","lv","desc","extrafil","extraop","matfilter","stage2","location","forcedselection","customoperation","specificmatfilter","requirementfunc","sumpos","extratg")

function Ritual.AddProcCode(c,_type,lv,desc,...)
	if not c:IsStatus(STATUS_COPYING_EFFECT) and c.fit_monster==nil then
		local mt=c:GetMetatable()
		mt.fit_monster={...}
	end
	return Ritual.AddProc(c,_type,Auxiliary.FilterBoolFunction(Card.IsCode,...),lv,desc)
end

function Ritual.AddProcGreaterCode(c,lv,desc,...)
	return Ritual.AddProcCode(c,RITPROC_GREATER,lv,desc,...)
end

--Ritual Summon, equal to
Ritual.AddProcEqual = aux.FunctionWithNamedArgs(
function(c,filter,lv,desc,extrafil,extraop,matfilter,stage2,location,forcedselection,customoperation,specificmatfilter,requirementfunc,sumpos,extratg)
	return Ritual.AddProc(c,RITPROC_EQUAL,filter,lv,desc,extrafil,extraop,matfilter,stage2,location,forcedselection,customoperation,specificmatfilter,requirementfunc,sumpos,extratg)
end,"handler","filter","lv","desc","extrafil","extraop","matfilter","stage2","location","forcedselection","customoperation","specificmatfilter","requirementfunc","sumpos","extratg")

function Ritual.AddProcEqualCode(c,lv,desc,...)
	return Ritual.AddProcCode(c,RITPROC_EQUAL,lv,desc,...)
end
