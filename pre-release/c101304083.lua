--JP name
--Shade the Obscure
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--You cannot Pendulum Summon, except Pendulum Monsters (this effect cannot be negated)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c,tp,sumtype,sumpos) return not c:IsPendulumMonster() and (sumtype&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM end)
	c:RegisterEffect(e1)
	--If a monster(s) with 1000 ATK or less is Special Summoned (except during the Damage Step): You can return this card to the hand. You can only use this effect of "Shade the Obscure" once per turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,{id,0})
	e2:SetCondition(function(e,tp,eg) return eg:IsExists(aux.FaceupFilter(Card.IsAttackBelow,1000),1,nil) end)
	e2:SetTarget(s.rthtg)
	e2:SetOperation(s.rthop)
	c:RegisterEffect(e2)
	--If you have a card in your Pendulum Zone and this card is in your hand: You can Special Summon this card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_HAND)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(function(e,tp) return Duel.GetFieldGroupCount(tp,LOCATION_PZONE,0)>0 end)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	--You can pay 1000 LP; destroy 1 Pendulum Monster Card in your hand or face-up field, then you can add 1 Pendulum Monster from your Deck to your face-up Extra Deck
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_TOEXTRA)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,2})
	e4:SetCost(Cost.PayLP(1000))
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
end
function s.rthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,0)
end
function s.rthop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.desfilter(c)
	return c:IsOriginalType(TYPE_PENDULUM) and (c:IsFaceup() or c:IsLocation(LOCATION_HAND))
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND|LOCATION_ONFIELD)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOEXTRA,nil,1,tp,LOCATION_DECK)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,1,nil)
	if #g==0 then return end
	if g:GetFirst():IsOnField() then Duel.HintSelection(g) end
	if Duel.Destroy(g,REASON_EFFECT)==0 then return end
	local dg=Duel.GetMatchingGroup(aux.AND(Card.IsPendulumMonster,Card.IsAbleToExtra),tp,LOCATION_DECK,0,nil)
	if #dg==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,3)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local sg=dg:Select(tp,1,1,nil)
	if #sg>0 then
		Duel.BreakEffect()
		Duel.SendtoExtraP(sg,tp,REASON_EFFECT)
	end
end