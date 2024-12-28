--深淵の相剣龍
--The Abyss Dragon Swordsoul
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableUnsummonable()
	--Must be Special Summoned by a Wyrm monster's effect
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	--Special Summon itself from the hand or GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e1:SetCode(EVENT_REMOVE)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Banish two cards if it this card is Special Summoned
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end
function s.splimit(e,se,sp,st)
	if not se:IsMonsterEffect() then return false end
	local rc=se:GetHandler()
	return rc:IsRelateToEffect(se) and rc:IsRace(RACE_WYRM) or rc:GetPreviousRaceOnField()&RACE_WYRM>0
end
function s.spcfilter(c)
	return c:IsReason(REASON_EFFECT) and c:IsFaceup() and c:IsMonster()
		and (not c:IsPreviousLocation(LOCATION_ONFIELD) or c:GetPreviousTypeOnField()&TYPE_MONSTER>0)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spcfilter,1,nil,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		c:CompleteProcedure()
		--Banish it if it leaves the field
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3300)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetReset(RESET_EVENT|RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
function s.rmrescon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_FZONE)==1
end
function s.rmfilter(c,e)
	return c:IsCanBeEffectTarget(e) and c:IsAbleToRemove() and (c:IsMonster() or c:IsLocation(LOCATION_FZONE))
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,LOCATION_FZONE,LOCATION_FZONE|LOCATION_MZONE|LOCATION_GRAVE,nil,e)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,2,s.rmrescon,0) end
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rmrescon,1,tp,HINTMSG_REMOVE)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg,#sg,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
	end
end