--ライジング・ホープ
--Utopia Rising
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 "Number 39: Utopia" from your Graveyard and equip it with this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(aux.RemainFieldCost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--When this card leaves the field, destroy the equipped monster
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
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0
		and c:IsRelateToEffect(e) and not c:IsStatus(STATUS_LEAVE_CONFIRMED) then
		Duel.HintSelection(tc,true)
		Duel.Equip(tp,c,tc)
		local eff_id=e:GetFieldID()
		tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1,eff_id)
		--Equip Limit
		local e0=Effect.CreateEffect(tc)
		e0:SetType(EFFECT_TYPE_SINGLE)
		e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e0:SetCode(EFFECT_EQUIP_LIMIT)
		e0:SetValue(function(e,c) return e:GetOwner()==c end)
		e0:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e0)
		--Equipped monster gains the effects of all Xyz Monsters you control that are activated by detaching their own Xyz Material(s)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_ADJUST)
		e1:SetLabelObject({})
		e1:SetLabel(eff_id)
		e1:SetOperation(s.copyop)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.src_check(src_eff)
	if src_eff:IsDeleted() or not src_eff:HasDetachCost() then return false end
	local src_c=src_eff:GetHandler()
	return src_c:IsFaceup() and src_c:IsType(TYPE_XYZ)
end
function s.copyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetOwner()
	local tc=c:GetEquipTarget()
	local effs=e:GetLabelObject()
	--it the card is no longer equipped, reset everything including this effect
	if not tc or tc:GetFlagEffectLabel(id)~=e:GetLabel() then
		for src_eff,eff in pairs(effs) do eff:Reset() end
		return e:Reset()
	end
	--reset copied effects that are no longer applicable, or if the equip card is currently negated
	for src_eff,eff in pairs(effs) do
		if c:IsDisabled() or not tc:IsCode(84013237) or not s.src_check(src_eff) then
			eff:Reset()
			effs[src_eff]=nil
		end
	end
	--copy effects that have not been copied already
	local xg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsType,TYPE_XYZ),tp,LOCATION_MZONE,0,tc)
	for xc in xg:Iter() do
		for _,eff in ipairs({xc:GetOwnEffects()}) do
			if not effs[eff] and eff:HasDetachCost() then
				local ce=eff:Clone()
				tc:RegisterEffect(ce)
				effs[eff]=ce
			end
		end
	end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
