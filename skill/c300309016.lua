--Harpie's Kaleidoscope
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,2,false,nil,nil)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.flipop)
	c:RegisterEffect(e1)
end
s.listed_series={0x1064} --"Harpie Lady Sisters" archetype
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local c=e:GetHandler()
	--"Harpie Lady Sisters" monsters you control cannot be destroyed by your opponent's Monster or Trap effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(0x5f)
	e1:SetTarget(function(e,c) return c:IsFaceup() and c:IsMonster() and c:IsHarpieLadySisters() end)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetValue(function(e,te) return (te:IsMonsterEffect() or te:IsTrapEffect()) and te:GetOwnerPlayer()==1-e:GetHandlerPlayer() end)
	Duel.RegisterEffect(e1,tp)
	--"Harpie Lady Sisters" monsters you control gain this effect: Once per turn, you place 2 Winged-Beast monsters from the GY on the bottom of the Deck in any order, then target 1 monster your opponent controls; return it to the hand
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,0))
	e2a:SetType(EFFECT_TYPE_IGNITION)
	e2a:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2a:SetCountLimit(1)
	e2a:SetRange(LOCATION_MZONE)
	e2a:SetCost(s.thcost)
	e2a:SetTarget(s.thtg)
	e2a:SetOperation(s.thop)
	local e2b=Effect.CreateEffect(c)
	e2b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e2b:SetTargetRange(LOCATION_MZONE,0)
	e2b:SetTarget(function(e,c) return c:IsFaceup() and c:IsCode(12206212) end)
	e2b:SetLabelObject(e2a)
	Duel.RegisterEffect(e2b,tp)
end
function s.costfilter(c)
	return c:IsRace(RACE_WINGEDBEAST) and c:IsAbleToDeckAsCost()
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	if #g>0 and Duel.SendtoDeck(g,tp,SEQ_DECKBOTTOM,REASON_COST)==2 then
		Duel.SortDeckbottom(tp,tp,2) 
	end
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsMonster() and chkc:IsAbleToHand() end
	if chk==0 then return Duel.IsExistingTarget(aux.AND(Card.IsMonster,Card.IsAbleToHand),tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,aux.AND(Card.IsMonster,Card.IsAbleToHand),tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
