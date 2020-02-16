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
			local clv=Ritual.SummoningLevel and Ritual.SummoningLevel or c:GetLevel()
			return (lv<<16)|clv
		else return lv end
	end
end
--Ritual Summon
Ritual.CreateProc = aux.FunctionWithNamedArgs(
function(c,_type,filter,lv,desc,extrafil,extraop,matfilter,stage2,location,forcedselection,customoperation,specificmatfilter)
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
	e1:SetTarget(Ritual.Target(filter,_type,lv,extrafil,extraop,matfilter,stage2,location,forcedselection,specificmatfilter))
	e1:SetOperation(Ritual.Operation(filter,_type,lv,extrafil,extraop,matfilter,stage2,location,forcedselection,customoperation,specificmatfilter))
	return e1
end,"handler","lvtype","filter","lv","desc","extrafil","extraop","matfilter","stage2","location","forcedselection","customoperation","specificmatfilter")

Ritual.AddProc = aux.FunctionWithNamedArgs(
function(c,_type,filter,lv,desc,extrafil,extraop,matfilter,stage2,location,forcedselection,customoperation,specificmatfilter)
	local e1=Ritual.CreateProc(c,_type,filter,lv,desc,extrafil,extraop,matfilter,stage2,location,forcedselection,customoperation,specificmatfilter)
	c:RegisterEffect(e1)
	return e1
end,"handler","lvtype","filter","lv","desc","extrafil","extraop","matfilter","stage2","location","forcedselection","customoperation","specificmatfilter")

function Ritual.Filter(c,filter,_type,e,tp,m,m2,forcedselection,lv)
	if not c:IsRitualMonster() or (filter and not filter(c)) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
	local lv=(lv and (type(lv)=="function" and lv()) or lv) or c:GetLevel()
	Ritual.SummoningLevel=lv
	local mg=m:Filter(Card.IsCanBeRitualMaterial,c,c)
	mg:Merge(m2-c)
	if c.ritual_custom_condition then
		return c:ritual_custom_condition(mg,forcedselection,_type)
	end
	if c.mat_filter then
		mg=mg:Filter(c.mat_filter,c,tp)
	end
	if specificmatfilter then
		mg=mg:Filter(specificmatfilter,nil,c,mg,tp)
	end
	if c.ritual_custom_check then
		forcedselection=aux.tableAND(c.ritual_custom_check,forcedselection or aux.TRUE)
	end
	local sg=Group.CreateGroup()
	local res=Ritual.Check(nil,sg,mg,tp,c,lv,forcedselection,e,_type)
	Ritual.SummoningLevel=nil
	return res
end

Ritual.Target = aux.FunctionWithNamedArgs(
function(filter,_type,lv,extrafil,extraop,matfilter,stage2,location,forcedselection)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				location = location or LOCATION_HAND
				if chk==0 then
					local mg=Duel.GetRitualMaterial(tp)
					local mg2=extrafil and extrafil(e,tp,eg,ep,ev,re,r,rp,chk) or Group.CreateGroup()
					Ritual.CheckMatFilter(matfilter,e,tp,mg,mg2)
					return Duel.IsExistingMatchingCard(Ritual.Filter,tp,location,0,1,e:GetHandler(),filter,_type,e,tp,mg,mg2,forcedselection,lv)
				end
				Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,location)
			end
end,"filter","lvtype","lv","extrafil","extraop","matfilter","stage2","location","forcedselection")

function Ritual.FastCheck(tp,lv,mg,sc,_type)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		if _type==RITPROC_EQUAL then
			return mg:CheckWithSumEqual(Card.GetRitualLevel,lv,0,#mg,sc)
		else
			return mg:CheckWithSumGreater(Card.GetRitualLevel,lv,sc)
		end
	else
		return mg:IsExists(Ritual.FilterF,1,nil,tp,mg,sc,lv,_type)
	end
end
function Ritual.FilterF(c,tp,mg,sc,lv,_type)
	if c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5 then
		Duel.SetSelectedCard(c)
		if _type==RITPROC_EQUAL then
			return mg:CheckWithSumEqual(Card.GetRitualLevel,lv,0,#mg,sc)
		else
			return mg:CheckWithSumGreater(Card.GetRitualLevel,lv,sc)
		end
	else return false end
end
function Ritual.Check(c,sg,mg,tp,sc,lv,forcedselection,e,_type)
	if not c and not forcedselection and #sg==0 then
		return Ritual.FastCheck(e:GetHandlerPlayer(),lv,mg,sc,_type)
	end
	if c then
		sg:AddCard(c)
	end
	local res=false
	local stop=false
	if _type==RITPROC_EQUAL then
		local cont=true
		res,cont=sg:CheckWithSumEqual(Card.GetRitualLevel,lv,#sg,#sg,sc)
		stop=not cont
	else
		Duel.SetSelectedCard(sg)
		local cont=true
		res,cont=sg:CheckWithSumGreater(Card.GetRitualLevel,lv,sc)
		stop=not cont
	end
	res=res and Duel.GetMZoneCount(tp,sg,tp)>0
	if res and forcedselection then
		res,stop=forcedselection(e,tp,sg,sc)
	end
	if not res and not stop then
		res=mg:IsExists(Ritual.Check,1,sg,sg,mg,tp,sc,lv,forcedselection,e,_type)
	end
	if c then
		sg:RemoveCard(c)
	end
	return res
end
function Ritual.SelectMaterials(sc,mg,forcedselection,lv,tp,e,_type)
	local sg=Group.CreateGroup()
	while true do
		local cg=mg:Filter(Ritual.Check,sg,sg,mg,tp,sc,lv,forcedselection,e,_type)
		if #cg==0 then break end
		local finish=Ritual.Check(nil,sg,sg,tp,sc,lv,forcedselection,e,_type)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local tc=cg:SelectUnselect(sg,tp,finish,finish,lv)
		if not tc then break end
		if not sg:IsContains(tc) then
			sg:AddCard(tc)
		else
			sg:RemoveCard(tc)
		end
	end
	return sg
end

Ritual.Operation = aux.FunctionWithNamedArgs(
function(filter,_type,lv,extrafil,extraop,matfilter,stage2,location,forcedselection,customoperation,specificmatfilter)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				location = location or LOCATION_HAND
				local mg=Duel.GetRitualMaterial(tp)
				local mg2=extrafil and extrafil(e,tp,eg,ep,ev,re,r,rp) or Group.CreateGroup()
				Ritual.CheckMatFilter(matfilter,e,tp,mg,mg2)
				local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Ritual.Filter),tp,location,0,1,1,e:GetHandler(),filter,_type,e,tp,mg,mg2,forcedselection,lv)
				if #tg>0 then
					local tc=tg:GetFirst()
					local lv=(lv and (type(lv)=="function" and lv()) or lv) or tc:GetLevel()
					Ritual.SummoningLevel=lv
					local mat=nil
					mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
					mg:Merge(mg2-tc)
					if specificmatfilter then
						mg=mg:Filter(specificmatfilter,nil,tc,mg,tp)
					end
					if tc.ritual_custom_operation then
						tc:ritual_custom_operation(mg,forcedselection,_type)
						mat=tc:GetMaterial()
					else
						if tc.ritual_custom_check then
							forcedselection=aux.tableAND(tc.ritual_custom_check,forcedselection or aux.TRUE)
						end
						if tc.mat_filter then
							mg=mg:Filter(tc.mat_filter,tc,tp)
						end
						if ft>0 and not forcedselection and not Auxiliary.RitualExtraCheck then
							Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
							if _type==RITPROC_EQUAL then
								mat=mg:SelectWithSumEqual(tp,Card.GetRitualLevel,lv,1,#mg,tc)
							else
								mat=mg:SelectWithSumGreater(tp,Card.GetRitualLevel,lv,tc)
							end
						else
							mat=Ritual.SelectMaterials(tc,mg,forcedselection,lv,tp,e,_type)
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
						Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
						tc:CompleteProcedure()
						if stage2 then
							stage2(mat,e,tp,eg,ep,ev,re,r,rp,tc)
						end
					else
						customoperation(mat:Clone(),e,tp,eg,ep,ev,re,r,rp,tc)
					end
					Ritual.SummoningLevel=nil
				end
			end
end,"filter","lvtype","lv","extrafil","extraop","matfilter","stage2","location","forcedselection","customoperation","specificmatfilter")

--Ritual Summon, geq fixed lv
Ritual.AddProcGreater = aux.FunctionWithNamedArgs(
function(c,filter,lv,desc,extrafil,extraop,matfilter,stage2,location,forcedselection,customoperation,specificmatfilter)
	return Ritual.AddProc(c,RITPROC_GREATER,filter,lv,desc,extrafil,extraop,matfilter,stage2,location,forcedselection,customoperation,specificmatfilter)
end,"handler","filter","lv","desc","extrafil","extraop","matfilter","stage2","location","forcedselection","customoperation","specificmatfilter")

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
function(c,filter,lv,desc,extrafil,extraop,matfilter,stage2,location,forcedselection,customoperation,specificmatfilter)
	return Ritual.AddProc(c,RITPROC_EQUAL,filter,lv,desc,extrafil,extraop,matfilter,stage2,location,forcedselection,customoperation,specificmatfilter)
end,"handler","filter","lv","desc","extrafil","extraop","matfilter","stage2","location","forcedselection","customoperation","specificmatfilter")

function Ritual.AddProcEqualCode(c,lv,desc,...)
	return Ritual.AddProcCode(c,RITPROC_EQUAL,lv,desc,...)
end
