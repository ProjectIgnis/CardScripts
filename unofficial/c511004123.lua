--ライジング・ホープ
--Utopia Rising
--Scripted by urielkama, fixed by ML, updated by the Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon N39 Utopia from GY and equip with this card
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(aux.RemainFieldCost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--Destroy Summoned monster if this card leaves the field
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
s.listed_names={84013237}
function s.spfilter(c,e,tp)
	return c:IsCode(84013237) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function s.eqlimit(e,c)
	return e:GetOwner()==c
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
		Duel.HintSelection(g,true)
		Duel.Equip(tp,c,tc)
		--Equip Limit
		local e0=Effect.CreateEffect(tc)
		e0:SetType(EFFECT_TYPE_SINGLE)
		e0:SetCode(EFFECT_EQUIP_LIMIT)
		e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e0:SetReset(RESET_EVENT+RESETS_STANDARD)
		e0:SetValue(s.eqlimit)
		c:RegisterEffect(e0)
		--Equipped monster gains effects of all other Xyz monsters on your field
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_ADJUST)
		e1:SetRange(LOCATION_MZONE)
		e1:SetOperation(s.copyop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
function s.copyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:GetEquipGroup():IsContains(e:GetOwner()) then e:Reset() return end
	if c:IsDisabled() then return end
	local map={}
	for _,eff in ipairs({c:GetCardEffect(511002571)}) do
		map[eff:GetLabel()]=true
	end
	for tc in Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsType,TYPE_XYZ),tp,LOCATION_MZONE,0,e:GetHandler()):Iter() do
		local code=tc:GetOriginalCode()
		if not map[code] then
			for _,te in ipairs({tc:GetCardEffect(511002571)}) do
				if te:GetLabel()==code then
					local teh=te:GetLabelObject()
					if teh:GetCode()&511001822==511001822 or teh:GetLabel()==511001822 then teh=teh:GetLabelObject() end
					local tec2=teh:Clone()
					c:RegisterEffect(tec2)
					local tec=te:Clone()
					c:RegisterEffect(tec)
					local rste=Effect.CreateEffect(e:GetOwner())
					rste:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
					rste:SetCode(EVENT_ADJUST)
					rste:SetLabelObject({tec2,tec})
					rste:SetLabel(code)
					rste:SetOperation(s.resetop)
					Duel.RegisterEffect(rste,tp)
				end
			end
		end
	end
end
function s.codechk(c,code)
	if not c:IsFaceup() or not c:IsType(TYPE_XYZ) then return false end
	for _,te in ipairs({c:GetCardEffect(511002571)}) do
		if te:GetLabel()==code then return true end
	end
	return false
end
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetOwner():GetEquipTarget()
	if not tc or tc:IsDisabled() or e:GetOwner():IsDisabled()
		or not Duel.IsExistingMatchingCard(s.codechk,tp,LOCATION_MZONE,0,1,tc,e:GetLabel()) then
		for _,eff in ipairs(e:GetLabelObject()) do
			if eff then
				eff:Reset()
			end
		end
		e:Reset()
	end
end