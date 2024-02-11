--真竜凰マリアムネ
--Mariamne, the True Dracophoenix
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon itself from the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Add 1 non-WIND Wyrm monster to the hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e) return e:GetHandler():IsReason(REASON_EFFECT) end)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
function s.desfilter(c)
	return c:IsMonster() and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
end
function s.desfilter2(c)
	return c:IsFaceup() and c:GetSequence()<5
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_WIND)
		and (Duel.GetMZoneCount(tp)>0 or sg:IsExists(Card.IsInMainMZone,1,nil,tp))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local loc=Duel.IsPlayerAffectedByEffect(tp,88581108) and LOCATION_MZONE or 0
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE|LOCATION_HAND,loc,c)
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and #g>=2 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	if #g==2 and g:FilterCount(Card.IsLocation,nil,LOCATION_HAND)<=1 then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
	else
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,2,tp,LOCATION_MZONE)
	end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local loc=Duel.IsPlayerAffectedByEffect(tp,88581108) and LOCATION_MZONE or 0
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE|LOCATION_HAND,loc,c)
	if #g<2 or not g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_WIND) then return end
	local dg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_DESTROY)
	local bnsh=dg:FilterCount(Card.IsAttribute,nil,ATTRIBUTE_WIND)==2
	if Duel.Destroy(dg,REASON_EFFECT)==2 then
		if not c:IsRelateToEffect(e) then return end
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then
			return
		end
		local rg=Duel.GetDecktopGroup(1-tp,4)
		if bnsh and #rg>0 and rg:FilterCount(Card.IsAbleToRemove,nil)==4
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.DisableShuffleCheck()
			Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
		end
	end
end
function s.thfilter(c)
	return c:IsAttributeExcept(ATTRIBUTE_WIND) and c:IsRace(RACE_WYRM) and c:IsAbleToHand()
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