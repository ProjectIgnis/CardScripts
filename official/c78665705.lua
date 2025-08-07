--古の呪文
--Ancient Chant
--Scripted by Hel
local s,id=GetID()
function s.initial_effect(c)
	--Add 1 "The Winged Dragon of Ra" from your Deck or GY to your hand, and if you do, you can Tribute Summon 1 monster during your Main Phase this turn, in addition to your Normal Summon/Set
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(function(e,tp) return Duel.IsPlayerCanSummon(tp) and Duel.IsPlayerCanAdditionalTributeSummon(tp) end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Apply an "if you Tribute Summon "The Winged Dragon of Ra" this turn, its original ATK/DEF become the combined original ATK/DEF of the monsters Tributed for its Summon" effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(function(e,tp) return not Duel.HasFlagEffect(tp,id) end)
	e2:SetCost(Cost.SelfBanish)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_RA}
function s.thfilter(c)
	return c:IsCode(CARD_RA) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,g)
		if not Duel.IsPlayerCanAdditionalTributeSummon(tp) then return end
		local c=e:GetHandler()
		aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,2))
		--You can Tribute Summon 1 monster during your Main Phase this turn, in addition to your Normal Summon/Set
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,3))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
		e1:SetTargetRange(LOCATION_HAND,0)
		e1:SetValue(0x1)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_EXTRA_SET_COUNT)
		Duel.RegisterEffect(e2,tp)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.HasFlagEffect(tp,id) then return end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	local c=e:GetHandler()
	aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,4))
	--If you Tribute Summon "The Winged Dragon of Ra" this turn, its original ATK/DEF become the combined original ATK/DEF of the monsters Tributed for its Summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(s.setatkdefop)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.setatkdefop(e,tp,eg,ep,ev,re,r,rp)
	local sc=eg:GetFirst()
	if sc:IsSummonPlayer(tp) and sc:IsTributeSummoned() and sc:IsCode(CARD_RA) then
		local mg=sc:GetMaterial()
		local atk=mg:GetSum(Card.GetBaseAttack)
		local def=mg:GetSum(Card.GetBaseDefense)
		--Its original ATK/DEF become the combined original ATK/DEF of the monsters Tributed for its Summon
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		sc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_BASE_DEFENSE)
		e2:SetValue(def)
		sc:RegisterEffect(e2)
	end
end