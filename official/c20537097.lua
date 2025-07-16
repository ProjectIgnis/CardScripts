--蒼穹の機界騎士
--Mekk-Knight Blue Sky
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--If 2 or more cards are in the same column, you can Special Summon this card (from your hand) in that column
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetValue(s.spval)
	c:RegisterEffect(e1)
	--Add "Mekk-Knight" monsters with different names, except "Mekk-Knight Blue Sky", from your Deck to your hand, equal to the number of your opponent's cards in this card's column
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,1))
	e2a:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2a:SetProperty(EFFECT_FLAG_DELAY)
	e2a:SetCode(EVENT_SUMMON_SUCCESS)
	e2a:SetCountLimit(1,{id,1})
	e2a:SetCondition(function(e) return e:GetHandler():IsSummonLocation(LOCATION_HAND) end)
	e2a:SetTarget(s.thtg)
	e2a:SetOperation(s.thop)
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2b)
end
s.listed_names={id}
s.listed_series={SET_MEKK_KNIGHT}
function s.spval(e,c)
	local zone=0
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(function(c) return c:GetColumnGroupCount()>0 end,0,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	for tc in g:Iter() do
		zone=(zone|tc:GetColumnZone(LOCATION_MZONE,0,0,tp))
	end
	return 0,zone
end
function s.thfilter(c)
	return c:IsSetCard(SET_MEKK_KNIGHT) and c:IsMonster() and not c:IsCode(id) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetHandler():GetColumnGroup():FilterCount(Card.IsControler,nil,1-tp)
	if chk==0 then return ct>0 and Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil):GetClassCount(Card.GetCode)>=ct end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,ct,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g==0 then return end
	local ct=c:GetColumnGroup():FilterCount(Card.IsControler,nil,1-tp)
	if c:IsControler(1-tp) then ct=ct+1 end
	if ct==0 or g:GetClassCount(Card.GetCode)<ct then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,ct,ct,aux.dncheck,1,tp,HINTMSG_ATOHAND)
	if #sg>0 then
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end