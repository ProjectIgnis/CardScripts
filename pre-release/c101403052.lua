--闇へ誘う太陽神
--The Sun God Leading Down into Darkness
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate this card by sending 1 "The Winged Dragon of Ra" monster from your hand, Deck, or face-up field to the GY
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCost(s.cost)
	c:RegisterEffect(e0)
	--During your Main Phase, if this card was activated this turn: You can add 1 "Sun God" monster from your Deck to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return e:GetHandler():HasFlagEffect(id)
	end)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--If a monster(s) is destroyed by battle: Its controller takes damage equal to its original ATK, then if you have "The Winged Dragon of Ra" in your GY, you gain 1000 LP
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.damtg)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_RA}
s.listed_series={SET_THE_WINGED_DRAGON_OF_RA,SET_SUN_GOD}
function s.costfilter(c)
	return c:IsSetCard(SET_THE_WINGED_DRAGON_OF_RA) and c:IsMonster() and (c:IsFaceup() or not c:IsOnField()) and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_MZONE,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
	e:GetHandler():RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,EFFECT_FLAG_OATH,1)
end
function s.thfilter(c)
	return c:IsSetCard(SET_SUN_GOD) and c:IsMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local dg_self,dg_opp=eg:Split(Card.IsPreviousControler,nil,tp)
	local your_total_atk,opp_total_atk,players=0,0,0
	if dg_self then
		your_total_atk=dg_self:GetSum(Card.GetBaseAttack)
		players=players|tp
	end
	if dg_opp then
		opp_total_atk=dg_opp:GetSum(Card.GetBaseAttack)
		players=players|(1-tp)
	end
	if dg_opp and dg_self then players=PLAYER_ALL end
	local cd=e:GetChainData()
	cd.your_damage=your_total_atk
	cd.oppo_damage=opp_total_atk
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,1,players,your_total_atk+opp_total_atk)
	if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,CARD_RA) then
		Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,1,tp,1000)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_RECOVER,nil,1,tp,1000)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local cd=e:GetChainData()
	local your_damage=cd.your_damage
	local oppo_damage=cd.oppo_damage
	local total_damage=0
	if your_damage>0 then
		total_damage=Duel.Damage(tp,your_damage,REASON_EFFECT,true)
	end
	if oppo_damage>0 then
		total_damage=total_damage+Duel.Damage(1-tp,oppo_damage,REASON_EFFECT,true)
	end
	Duel.RDComplete()
	if total_damage>0 and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,CARD_RA) then
		Duel.BreakEffect()
		Duel.Recover(tp,1000,REASON_EFFECT)
	end
end