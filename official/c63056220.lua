--メガリス・オフィエル
--Megalith Ophiel
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Add 1 "Megalith" monster from your Deck to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(function(e) return e:GetHandler():IsRitualSummoned() end)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local ritual_params={handler=c,lvtype=RITPROC_GREATER,forcedselection=function(e,tp,g,sc) return g:IsContains(e:GetHandler()) end}
	--Ritual Summon 1 Ritual Monster from your hand, by Tributing monsters from your hand or field, including this card on your field, whose total Levels equal or exceed the Level of the Ritual Monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(Ritual.Target(ritual_params))
	e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
						local c=e:GetHandler()
						if c:IsRelateToEffect(e) and c:IsControler(tp) then
							Ritual.Operation(ritual_params)(e,tp,eg,ep,ev,re,r,rp)
						end
					end)
	c:RegisterEffect(e2)
end
s.listed_series={SET_MEGALITH}
s.listed_names={id}
function s.thfilter(c)
	return c:IsSetCard(SET_MEGALITH) and c:IsMonster() and not c:IsCode(id) and c:IsAbleToHand()
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