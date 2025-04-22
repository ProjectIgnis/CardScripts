--原石融合
--Primite Fusion
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon 1 Dragon Fusion Monster from your Extra Deck, by shuffling its materials from your field, GY, and/or banishment into the Deck, including a Normal Monster
	local e1=Fusion.CreateSummonEff({handler=c,fusfilter=aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),matfilter=aux.FALSE,extrafil=s.fextra,extraop=Fusion.ShuffleMaterial,extratg=s.extratg})
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
	--Add 1 Level 5 or higher "Primite" monster from your Deck or GY to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_PRIMITE}
function s.fextrafil(c)
	return c:IsAbleToDeck() and (c:IsOnField() or c:IsFaceup())
end
function s.fcheck(tp,sg,fc)
	return sg:IsExists(Card.IsType,1,nil,TYPE_NORMAL)
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(s.fextrafil),tp,LOCATION_ONFIELD|LOCATION_GRAVE|LOCATION_REMOVED,0,nil),s.fcheck
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_ONFIELD|LOCATION_GRAVE|LOCATION_REMOVED)
end
function s.thfilter(c)
	return c:IsLevelAbove(5) and c:IsSetCard(SET_PRIMITE) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end