--沈黙狼－カルーポ
--Silent Wolf Calupo
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Equip the top card of your Deck to this card
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
	--Your opponent calls the original type of the Equip Card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOGRAVE+CATEGORY_HANDES+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(function(e) return e:GetHandler():GetEquipGroup():IsExists(Card.HasFlagEffect,1,nil,id) end)
	e3:SetTarget(s.calltg)
	e3:SetOperation(s.callop)
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
	if not ec then return end
	Duel.DisableShuffleCheck()
	if not c:EquipByEffectAndLimitRegister(e,tp,ec,id,false) then return end
	--The equipped monster gains 500 ATK
	local e1=Effect.CreateEffect(ec)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(500)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	ec:RegisterEffect(e1)
	--Equip limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetValue(function(e,_c) return _c==c end)
	e2:SetReset(RESET_EVENT|RESETS_STANDARD)
	ec:RegisterEffect(e2)
end
function s.calltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,c,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,c,1,tp,0)
end
function s.callop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local ec=c:GetEquipGroup():Filter(Card.HasFlagEffect,nil,id):GetFirst()
	if not ec then return end
	local op=Duel.SelectOption(1-tp,DECLTYPE_MONSTER,DECLTYPE_SPELL,DECLTYPE_TRAP)
	Duel.ConfirmCards(1-tp,ec)
	local res=(op==0 and ec:IsMonsterCard())
		or (op==1 and ec:IsSpellCard())
		or (op==2 and ec:IsTrapCard())
	if res then
		--Send this card to the GY
		Duel.SendtoGrave(c,REASON_EFFECT)
	else
		--Discard 1 random card from your opponent's hand, and if you do, return this card to the hand
		local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND,nil)
		if #g==0 then return end
		local sg=g:RandomSelect(1-tp,1)
		if Duel.SendtoGrave(sg,REASON_DISCARD|REASON_EFFECT)>0 then
			Duel.SendtoHand(c,nil,REASON_EFFECT)
		end
	end
end