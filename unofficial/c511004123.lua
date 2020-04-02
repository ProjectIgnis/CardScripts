--Utopia Rising
--scripted by:urielkama
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--Destroy
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
	if tc then
		Duel.HintSelection(g)
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		Duel.Equip(tp,c,tc)
		local e0=Effect.CreateEffect(tc)
		e0:SetType(EFFECT_TYPE_SINGLE)
		e0:SetCode(EFFECT_EQUIP_LIMIT)
		e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e0:SetReset(RESET_EVENT+RESETS_STANDARD)
		e0:SetValue(s.eqlimit)
		c:RegisterEffect(e0)
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
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
function s.copyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:GetEquipGroup():IsContains(e:GetOwner()) then e:Reset() return end
	if c:IsDisabled() then return end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,e:GetHandler())
	local tc=g:GetFirst()
	while tc do
		local code=tc:GetOriginalCode()
		if tc:IsHasEffect(511002571) then
			local teff={tc:GetCardEffect(511002571)}
			for _,te in ipairs(teff) do
				local code=te:GetLabel()
				local ceff={c:GetCardEffect(511002571)}
				local ok=true
				for _,te2 in ipairs(ceff) do
					if code==te2:GetLabel() then ok=false end
					if ok then break end
				end
				if ok then
					local copye={}
					for k,te3 in ipairs(teff) do
						if te3:GetLabel()==code then
							table.insert(copye,teff[k])
						end
					end
					for _,te4 in ipairs(copye) do
						local tec2=te4:GetLabelObject():Clone()
						c:RegisterEffect(tec2)
						local tec=te4:Clone()
						tec:SetLabelObject(tec2)
						c:RegisterEffect(tec)
						local rste=Effect.CreateEffect(e:GetOwner())
						rste:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
						rste:SetCode(EVENT_ADJUST)
						rste:SetLabelObject(tec)
						rste:SetLabel(code)
						rste:SetOperation(s.resetop)
						Duel.RegisterEffect(rste,tp)
					end
				end
			end
		end
		tc=g:GetNext()
	end
end
function s.codechk(c,code)
	if not c:IsHasEffect(511002571) then return false end
	local eff={c:GetCardEffect(511002571)}
	for _,te in ipairs(eff) do
		if te:GetLabel()==code then return true end
	end
	return false
end
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetOwner():GetEquipTarget()
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,tc)
	if not g:IsExists(s.codechk,1,nil,e:GetLabel()) or tc:IsDisabled() or e:GetOwner():IsDisabled() then
		local te1=e:GetLabelObject()
		local te2=te1:GetLabelObject()
		if te2 then
			te2:Reset()
		end
		if te1 then
			te1:Reset()
		end
		e:Reset()
	end
end
