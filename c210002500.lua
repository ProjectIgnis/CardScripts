--Dark Magic Endow
--scripted by Larry126
function c210002500.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c210002500.cost)
	e1:SetTarget(c210002500.target)
	e1:SetOperation(c210002500.activate)
	c:RegisterEffect(e1)
end
c210002500.listed_names={46986414,38033121,30208479,210002500,0xa1}
function c210002500.costfilter(c)
	return c:IsDiscardable() and
		((c:IsSetCard(0xa1) and c:IsType(TYPE_SPELL)) or
		c:IsCode(15256925,76792184,
		7084129,13722870,29436665,
		30603688,35191415,71696014,
		71703785,73752131,75380687,
		92377303,98502113) or
		aux.IsCodeListed(c,46986414,38033121,30208479) or
		(c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsLevelAbove(6)))
end
function c210002500.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c210002500.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.DiscardHand(tp,c210002500.costfilter,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end
function c210002500.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function c210002500.activate(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end