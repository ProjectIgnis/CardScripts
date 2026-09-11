--リインゼルム・ルヴィアン
--Reindsurm Luvian
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--If this card is Ritual Summoned: You can add 2 "Reindsurm" Spells/Traps from your Deck to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return e:GetHandler():IsRitualSummoned()
	end)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--If this card is sent to the GY, except by battle: You can Ritual Summon 1 Insect Ritual Monster from your hand, by Tributing monsters from your hand or field, and/or shuffling Insect and/or Dragon monsters from your GY into the Deck, whose total Levels equal or exceed its Level
	local ritual_params={
		lvtype=RITPROC_GREATER,
		filter=function(c)
			return c:IsRace(RACE_INSECT)
		end,
		extratg=function(e,tp,eg,ep,ev,re,r,rp,chk)
			if chk==0 then return true end
			Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
		end,
		extraop=function(mg,e,tp,eg,ep,ev,re,r,rp)
			local gymg,hfmg=mg:Split(Card.IsLocation,nil,LOCATION_GRAVE)
			if #hfmg>0 then
				Duel.ReleaseRitualMaterial(hfmg)
			end
			if #gymg>0 then
				Duel.HintSelection(gymg)
				Duel.SendtoDeck(gymg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT|REASON_RITUAL|REASON_MATERIAL)
			end
		end,
		extrafil=function(e,tp,mg)
			local matfilter=not Duel.IsChainSolving() and s.extramatfilter or aux.NecroValleyFilter(s.extramatfilter)
			return Duel.GetMatchingGroup(matfilter,tp,LOCATION_GRAVE,0,nil)
		end
	}
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RELEASE+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return not e:GetHandler():IsReason(REASON_BATTLE)
	end)
	e2:SetTarget(Ritual.Target(ritual_params))
	e2:SetOperation(Ritual.Operation(ritual_params))
	c:RegisterEffect(e2)
end
s.listed_names={101403055} --"Reindsurm Conquest"
s.listed_series={SET_REINDSURM}
function s.thfilter(c)
	return c:IsSetCard(SET_REINDSURM) and c:IsSpellTrap() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,2,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,2,2,nil)
	if #g==2 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.extramatfilter(c)
	return c:IsRace(RACE_INSECT|RACE_DRAGON) and c:HasLevel() and c:IsAbleToDeck()
end