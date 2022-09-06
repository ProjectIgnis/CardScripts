--沈黙狼－カルーポ
--Omerta - Calupoh
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Equip the top card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--Opponent must guess the card at the End Phase
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOGRAVE+CATEGORY_HANDES+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.condition)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local ec=Duel.GetDecktopGroup(tp,1):GetFirst()
	if ec then
		Duel.DisableShuffleCheck()
		s.equipop(c,e,tp,ec)
	end
end
function s.equipop(c,e,tp,tc)
	if not c:EquipByEffectAndLimitRegister(e,tp,tc,id,false) then return end
	--ATK increase
	local e1=Effect.CreateEffect(tc)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetValue(500)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	--Equip limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(s.eqlimit)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e2)
end
function s.eqlimit(e,c)
	return c:GetControler()==e:GetHandlerPlayer()
end
function s.eqfilter(c)
	return c:GetFlagEffect(id)>0
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetEquipGroup():Filter(s.eqfilter,nil)
	return #g>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,c,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,c,1,tp,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local eg=c:GetEquipGroup():Filter(s.eqfilter,nil)
	if not eg or #eg==0 then return end
	local op=Duel.SelectOption(1-tp,70,71,72)
	Duel.ConfirmCards(1-tp,eg:GetFirst())
	local res=s.testtype(op,eg:GetFirst())
	if res then --correctly guessed
		Duel.SendtoGrave(c,REASON_EFFECT)
	else --incorrectly guessed
		local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND,nil)
		if #g==0 then return end
		local sg=g:RandomSelect(1-tp,1)
		if Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)>0 then
			Duel.SendtoHand(c,nil,REASON_EFFECT)
		end
	end
end
function s.testtype(op,c)
	return (op==0 and c:IsOriginalType(TYPE_MONSTER))
		or (op==1 and c:IsOriginalType(TYPE_SPELL))
		or (op==2 and c:IsOriginalType(TYPE_TRAP))
end
