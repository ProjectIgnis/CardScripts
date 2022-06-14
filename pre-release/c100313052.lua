-- 暗黒界の登極
-- Dark World Accession
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Fusion Summon
	local e1=Fusion.CreateSummonEff({handler=c,fusfilter=aux.FilterBoolFunction(Card.IsRace,RACE_FIEND),matfilter=s.matfilter,extrafil=s.fextra,extraop=s.extraop,extratg=s.extratg})
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCondition(function() return Duel.IsMainPhase() end)
	c:RegisterEffect(e1)
	-- Add this card to the hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={0x6}
function s.matfilter(c)
	return (c:IsLocation(LOCATION_HAND) and c:IsDiscardable(REASON_EFFECT+REASON_FUSION+REASON_MATERIAL))
		or (c:IsOnField() and c:IsAbleToRemove())
end
function s.checkmat(tp,sg,fc)
	return fc:IsSetCard(0x6) or not sg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND)
end
function s.fextra(e,tp,mg)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_SPIRIT_ELIMINATION) then return nil,s.checkmat end
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil),s.checkmat
end
function s.extraop(e,tc,tp,sg)
	local rg=sg:Filter(Card.IsLocation,nil,LOCATION_HAND)
	if #rg>0 then
		Duel.SendtoGrave(rg,REASON_DISCARD+REASON_EFFECT+REASON_FUSION+REASON_MATERIAL)
		sg:Sub(rg)
	end
	Fusion.BanishMaterial(e,tc,tp,sg)
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_MZONE+LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function s.tgfilter(c)
	return c:IsSetCard(0x6) and c:IsMonster() and c:IsDiscardable(REASON_EFFECT)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)>0 and c:IsLocation(LOCATION_HAND)) then return end
	Duel.ShuffleHand(tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND,0,1,1,nil)
	if #g>0 then
		Duel.BreakEffect()
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
	end
end