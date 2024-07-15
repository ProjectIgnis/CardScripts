--Japanese name
--The League of Uniform Nomenclature Strikes
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Equip 2 monsters with the same original name as a target to that target
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
end
function s.tgfilter(c,tp)
	return c:IsFaceup() and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,2,nil,tp,c:GetOriginalCodeRule())
end
function s.eqfilter(c,tp,code)
	return c:IsOriginalCodeRule(code) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.tgfilter(chkc,tp) end
	if chk==0 then
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if e:GetHandler():IsLocation(LOCATION_HAND) then ft=ft-1 end
		return ft>=2 and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,2,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local eqg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,2,2,nil,tp,tc:GetOriginalCodeRule())
	if #eqg==2 then
		local fid=e:GetFieldID()
		local equip_success=false
		for ec in eqg:Iter() do
			if Duel.Equip(tp,ec,tc,true,true) then
				equip_success=true
				ec:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1,fid)
				--Equip limit
				local e1=Effect.CreateEffect(ec)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetCode(EFFECT_EQUIP_LIMIT)
				e1:SetValue(function(e,c) return c==tc end)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD)
				ec:RegisterEffect(e1)
			end
		end
		Duel.EquipComplete()
		if equip_success then
			local ec1,ec2=eqg:GetFirst(),eqg:GetNext()
			--Cannot attack while equipped with those 2 cards
			local e2=Effect.CreateEffect(c)
			e2:SetDescription(aux.Stringid(id,1))
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e2:SetCode(EFFECT_CANNOT_ATTACK)
			e2:SetCondition(function(e) return e:GetHandler():GetEquipGroup():IsExists(function(ec) return ec:GetFlagEffectLabel(id)==fid end,2,nil) end)
			e2:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e2)
			--Cannot be destroyed by battle while equipped with those 2 cards
			local e3=e2:Clone()
			e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e3:SetValue(1)
			tc:RegisterEffect(e3)
		end
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	--Cannot Special Summon for the rest of this turn after this card resolves, except monsters with the same original Type as the targeted monster
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e4:SetTargetRange(1,0)
	e4:SetTarget(function(e,c) return not c:IsOriginalRace(tc:GetOriginalRace()) end)
	e4:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e4,tp)
end