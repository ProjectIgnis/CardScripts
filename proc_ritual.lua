if not aux.RitualProcedure then
	aux.RitualProcedure = {}
	Ritual = aux.RitualProcedure
end
if not Ritual then
	Ritual = aux.RitualProcedure
end
function Ritual.CheckForcedGroup(forcedgroup,e,tp,mg,mg2)
	if forcedgroup then
		if type(forcedgroup)=="function" then
			mg:Sub(mg:Filter(aux.NOT(forcedgroup),nil,e,tp))
			mg2:Sub(mg2:Filter(aux.NOT(forcedgroup),nil,e,tp))
		else
			local f=function(c)
						return not forcedgroup:IsContains(c)
					end
			mg:Sub(mg:Filter(f,nil))
			mg2:Sub(mg2:Filter(f,nil))
		end
	end
end
--Ritual Summon, geq fixed lv
function Ritual.AddProcGreater(c,filter,desc,extrafil,extraop,forcedgroup,stage2,location)
	local e1=Effect.CreateEffect(c)
	if desc then
		e1:SetDescription(desc)
	else
		e1:SetDescription(1171)
	end
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(Ritual.GreaterTarget(filter,extrafil,extraop,forcedgroup,stage2,location))
	e1:SetOperation(Ritual.GreaterOperation(filter,extrafil,extraop,forcedgroup,stage2,location))
	c:RegisterEffect(e1)
	return e1
end
function Ritual.GreaterFilter(c,filter,e,tp,m,m2,ft)
	if not c:IsRitualMonster() or (filter and not filter(c)) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
	local mg=m:Filter(Card.IsCanBeRitualMaterial,c,c)
	mg:Merge(m2-c)
	if c.ritual_custom_condition then
		return c:ritual_custom_condition(mg,ft,"greater")
	end
	if c.mat_filter then
		mg=mg:Filter(c.mat_filter,c,tp)
	end
	if ft>0 then
		return mg:CheckWithSumGreater(Card.GetRitualLevel,c:GetOriginalLevel(),c)
	else
		return mg:IsExists(Ritual.GreaterFilterF,1,nil,tp,mg,c)
	end
end
function Ritual.GreaterFilterF(c,tp,mg,rc)
	if c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5 then
		Duel.SetSelectedCard(c)
		return mg:CheckWithSumGreater(Card.GetRitualLevel,rc:GetOriginalLevel(),rc)
	else return false end
end
function Ritual.GreaterTarget(filter,extrafil,extraop,forcedgroup,stage2,location)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				location = location or LOCATION_HAND
				if chk==0 then
					local mg=Duel.GetRitualMaterial(tp)
					local mg2=extrafil and extrafil(e,tp,eg,ep,ev,re,r,rp,chk) or Group.CreateGroup()
					Ritual.CheckForcedGroup(forcedgroup,e,tp,mg,mg2)
					local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
					return ft>-1 and Duel.IsExistingMatchingCard(Ritual.GreaterFilter,tp,location,0,1,nil,filter,e,tp,mg,mg2,ft)
				end
				Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,location)
			end
end
function Ritual.GreaterOperation(filter,extrafil,extraop,forcedgroup,stage2,location)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				location = location or LOCATION_HAND
				local mg=Duel.GetRitualMaterial(tp)
				local mg2=extrafil and extrafil(e,tp,eg,ep,ev,re,r,rp,chk) or Group.CreateGroup()
				Ritual.CheckForcedGroup(forcedgroup,e,tp,mg,mg2)
				local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local tg=Duel.SelectMatchingCard(tp,Ritual.GreaterFilter,tp,location,0,1,1,nil,filter,e,tp,mg,mg2,ft)
				local tc=tg:GetFirst()
				if tc then
					mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
					mg:Merge(mg2-tc)
					local mat=nil
					if tc.ritual_custom_operation then
						tc:ritual_custom_operation(mg,"greater")
						mat=tc:GetMaterial()
					else
						if tc.mat_filter then
							mg=mg:Filter(tc.mat_filter,tc,tp)
						end
						if ft>0 then
							Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
							mat=mg:SelectWithSumGreater(tp,Card.GetRitualLevel,tc:GetOriginalLevel(),tc)
						else
							Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
							mat=mg:FilterSelect(tp,Ritual.GreaterFilterF,1,1,nil,tp,mg,tc)
							Duel.SetSelectedCard(mat)
							Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
							local mat2=mg:SelectWithSumGreater(tp,Card.GetRitualLevel,tc:GetOriginalLevel(),tc)
							mat:Merge(mat2)
						end
						tc:SetMaterial(mat)
					end
					if extraop then
						extraop(mat,e,tp,eg,ep,ev,re,r,rp)
					else
						Duel.ReleaseRitualMaterial(mat)
					end
					Duel.BreakEffect()
					Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
					tc:CompleteProcedure()
					if stage2 then
						stage2(mat,e,tp,eg,ep,ev,re,r,rp,tc)
					end
				end
			end
end
function Ritual.AddProcGreaterCode(c,...)
	if not c:IsStatus(STATUS_COPYING_EFFECT) and c.fit_monster==nil then
		local code=c:GetOriginalCode()
		local mt=_G["c" .. code]
		mt.fit_monster={...}
	end
	return Ritual.AddProcGreater(c,Auxiliary.FilterBoolFunction(Card.IsCode,...))
end
--Ritual Summon, equal to
function Ritual.AddProcEqual(c,filter,lv,desc,extrafil,extraop,forcedgroup,stage2,location)
	--lv can be nil, otherwise, fixed level
	local e1=Effect.CreateEffect(c)
	if desc then
		e1:SetDescription(desc)
	else
		e1:SetDescription(1057)
	end
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(Ritual.EqualTarget(filter,lv,extrafil,extraop,forcedgroup,stage2,location))
	e1:SetOperation(Ritual.EqualOperation(filter,lv,extrafil,extraop,forcedgroup,stage2,location))
	c:RegisterEffect(e1)
	return e1
end
function Ritual.EqualFilter(c,filter,e,tp,m,m2,ft,lv)
	if not c:IsRitualMonster() or (filter and not filter(c)) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
	local mg=m:Filter(Card.IsCanBeRitualMaterial,c,c)
	mg:Merge(m2-c)
	if c.ritual_custom_condition then
		return c:ritual_custom_condition(mg,ft,"equal")
	end
	if c.mat_filter then
		mg=mg:Filter(c.mat_filter,c,tp)
	end
	if ft>0 then
		local lv=lv or c:GetLevel()
		return mg:CheckWithSumEqual(Card.GetRitualLevel,lv,1,99,c)
	else
		return mg:IsExists(Ritual.EqualFilterF,1,nil,tp,mg,c,lv)
	end
end
function Ritual.EqualFilterF(c,tp,mg,rc,lv)
	if c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5 then
		Duel.SetSelectedCard(c)
		local lv=lv or rc:GetLevel()
		return mg:CheckWithSumEqual(Card.GetRitualLevel,lv,0,99,rc)
	else return false end
end
function Ritual.EqualTarget(filter,lv,extrafil,extraop,forcedgroup,stage2,location)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				location = location or LOCATION_HAND
				if chk==0 then
					local mg=Duel.GetRitualMaterial(tp)
					local mg2=extrafil and extrafil(e,tp,eg,ep,ev,re,r,rp,chk) or Group.CreateGroup()
					Ritual.CheckForcedGroup(forcedgroup,e,tp,mg,mg2)
					local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
					return ft>-1 and Duel.IsExistingMatchingCard(Ritual.EqualFilter,tp,location,0,1,nil,filter,e,tp,mg,mg2,ft,lv)
				end
				Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,location)
			end
end
function Ritual.EqualOperation(filter,lv,extrafil,extraop,forcedgroup,stage2,location)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				location = location or LOCATION_HAND
				local mg=Duel.GetRitualMaterial(tp)
				local mg2=extrafil and extrafil(e,tp,eg,ep,ev,re,r,rp) or Group.CreateGroup()
				Ritual.CheckForcedGroup(forcedgroup,e,tp,mg,mg2)
				local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local tg=Duel.SelectMatchingCard(tp,Ritual.EqualFilter,tp,location,0,1,1,nil,filter,e,tp,mg,mg2,ft,lv)
				local tc=tg:GetFirst()
				if tc then
					local mat=nil
					mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
					mg:Merge(mg2-tc)
					if tc.ritual_custom_operation then
						tc:ritual_custom_operation(mg,"equal")
						mat=tc:GetMaterial()
					else
						if tc.mat_filter then
							mg=mg:Filter(tc.mat_filter,tc,tp)
						end
						if ft>0 then
							local lv=lv or tc:GetLevel()
							Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
							mat=mg:SelectWithSumEqual(tp,Card.GetRitualLevel,lv,1,99,tc)
						else
							Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
							mat=mg:FilterSelect(tp,Ritual.EqualFilterF,1,1,nil,tp,mg,tc,lv)
							Duel.SetSelectedCard(mat)
							local lv=lv or tc:GetLevel()
							Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
							local mat2=mg:SelectWithSumEqual(tp,Card.GetRitualLevel,lv,0,99,tc)
							mat:Merge(mat2)
						end
						tc:SetMaterial(mat)
					end
					if extraop then
						extraop(mat,e,tp,eg,ep,ev,re,r,rp)
					else
						Duel.ReleaseRitualMaterial(mat)
					end
					Duel.BreakEffect()
					Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
					tc:CompleteProcedure()
					if stage2 then
						stage2(mat,e,tp,eg,ep,ev,re,r,rp,tc)
					end
				end
			end
end
function Ritual.AddProcEqualCode(c,lv,desc,...)
	if not c:IsStatus(STATUS_COPYING_EFFECT) and c.fit_monster==nil then
		local code=c:GetOriginalCode()
		local mt=_G["c" .. code]
		mt.fit_monster={...}
	end
	return Ritual.AddProcEqual(c,Auxiliary.FilterBoolFunction(Card.IsCode,...),lv,desc)
end
