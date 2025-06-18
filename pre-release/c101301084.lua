--
--Miracle Raven
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Pendulum.AddProcedure(c)
	c:AddMustBeRitualSummoned()
	--Ritual Summon this card, by Tributing monsters from your hand or field whose total Levels equal or exceed 1
	local e1=Ritual.CreateProc({
			handler=c,
			lvtype=RITPROC_GREATER,
			filter=function(rc) return rc==c end,
			lv=1,
			location=LOCATION_PZONE,
			desc=aux.Stringid(id,0),
			self=true
	})
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	c:RegisterEffect(e1)
	--This Ritual Summoned card is unaffected by your opponent's activated effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(function(e) return e:GetHandler():IsRitualSummoned() end)
	e2:SetValue(function(e,te) return te:IsActivated() and te:GetOwnerPlayer()==1-e:GetHandlerPlayer() end)
	c:RegisterEffect(e2)
	--If you Ritual Summon exactly 1 Ritual Monster with a card effect that requires use of monsters, this card you control can be used as the entire Tribute
	local e3=Ritual.AddWholeLevelTribute(c,aux.TRUE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	--Add 1 Ritual Monster from your Deck to your hand
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_RELEASE)
	e4:SetCondition(function(e) return e:GetHandler():IsReason(REASON_RITUAL) end)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
s.listed_names={id}
function s.thfilter(c)
	return c:IsRitualMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end