--ＧＤロボ・オービタル ７
--Galaxy Defense Robot Orbital 7
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--You can Tribute this card from your hand or field; take 1 "Photon" monster and 1 "Galaxy" monster from your Deck, add 1 of them to your hand, and send the other to the GY, also you cannot Special Summon for the rest of this turn, except LIGHT monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND|LOCATION_MZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(Cost.SelfTribute)
	e1:SetTarget(s.thtgtg)
	e1:SetOperation(s.thtgop)
	c:RegisterEffect(e1)
	--If a "Galaxy-Eyes" monster(s) is Special Summoned to your field: You can Special Summon this card from your GY, but banish it when it leaves the field
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_PHOTON,SET_GALAXY,SET_GALAXY_EYES}
function s.thtgfilter(c)
	return c:IsSetCard({SET_PHOTON,SET_GALAXY}) and c:IsMonster() and (c:IsAbleToHand() or c:IsAbleToGrave())
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.IsSetCard,1,nil,SET_PHOTON) and sg:IsExists(Card.IsSetCard,1,nil,SET_GALAXY)
		and sg:IsExists(Card.IsAbleToHand,1,nil) and sg:IsExists(Card.IsAbleToGrave,1,nil)
end
function s.thtgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.thtgfilter,tp,LOCATION_DECK,0,nil)
		return #g>=2 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.thtgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thtgfilter,tp,LOCATION_DECK,0,nil)
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,aux.Stringid(id,2))
	if #sg==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local hg=sg:FilterSelect(tp,Card.IsAbleToHand,1,1,nil)
		Duel.SendtoHand(hg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,hg)
		Duel.SendtoGrave(sg-hg,REASON_EFFECT)
	end
	--You cannot Special Summon for the rest of this turn, except LIGHT monsters
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return c:IsAttributeExcept(ATTRIBUTE_LIGHT) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.spconfilter(c,tp)
	return c:IsSetCard(SET_GALAXY_EYES) and c:IsControler(tp) and c:IsFaceup()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spconfilter,1,nil,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		--Banish it when it leaves the field
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3300)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT|RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
	end
end