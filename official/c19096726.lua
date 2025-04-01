--鉄獣鳥 メルクーリエ
--Tri-Brigade Mercourier
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Negate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND|LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.negcon)
	e1:SetCost(Cost.SelfToGrave)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	--Search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_ALBAZ,id}
function s.negconfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:ListsCodeAsMaterial(CARD_ALBAZ)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsMonsterEffect()
		and Duel.IsExistingMatchingCard(s.negconfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsChainDisablable(ev) and not re:GetHandler():IsStatus(STATUS_DISABLED) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end
function s.thfilter(c)
	return (c:IsCode(CARD_ALBAZ) or (c:IsMonster() and c:ListsCode(CARD_ALBAZ)))
		and c:IsAbleToHand() and not c:IsCode(id)
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