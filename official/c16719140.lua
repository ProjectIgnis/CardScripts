--サブテラーの戦士
--Subterror Nemesis Warrior
local s,id=GetID()
function s.initial_effect(c)
	--Tribute this card and at least 1 other monster and Special Summon 1 "Subterror" monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON+CATEGORY_SET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetCost(s.subspcost)
	e1:SetTarget(s.subsptg)
	e1:SetOperation(s.subspop)
	c:RegisterEffect(e1)
	--Special Summon this card
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,1))
	e2a:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2a:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e2a:SetCode(EVENT_FLIP)
	e2a:SetRange(LOCATION_GRAVE)
	e2a:SetCountLimit(1,{id,1})
	e2a:SetCondition(s.selfspcon)
	e2a:SetTarget(s.selfsptg)
	e2a:SetOperation(s.selfspop)
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetCode(EVENT_BATTLED)
	e2b:SetCondition(function(e) return e:GetHandler():HasFlagEffect(id) end)
	c:RegisterEffect(e2b)
	--Keep track of a "Subterror Behemoth" being flipped face-up for battle
	local e2c=Effect.CreateEffect(c)
	e2c:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2c:SetCode(EVENT_FLIP)
	e2c:SetRange(LOCATION_GRAVE)
	e2c:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp==PLAYER_NONE and eg:IsExists(s.selfspconfilter,1,nil,tp) end)
	e2c:SetOperation(function(e) e:GetHandler():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_DAMAGE,0,1) end)
	c:RegisterEffect(e2c)
end
s.listed_series={SET_SUBTERROR,SET_SUBTERROR_BEHEMOTH}
function s.subspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function s.costfilter(c,e,tp,mg,rlv)
	if not (c:HasLevel() and c:IsSetCard(SET_SUBTERROR) and c:IsMonster() and c:IsAbleToGraveAsCost()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_DEFENSE)) then return false end
	local lv=c:GetLevel()-rlv
	return #mg>0 and (lv<=0 or mg:CheckWithSumGreater(Card.GetOriginalLevel,lv))
end
function s.subsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local mg=Duel.GetReleaseGroup(tp,false,false,REASON_EFFECT):Filter(Card.IsLevelAbove,nil,1)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		if not mg:IsContains(c) then return false end
		mg:RemoveCard(c)
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>-2
			and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK,0,1,nil,e,tp,mg,c:GetOriginalLevel())
	end
	e:SetLabel(0)
	mg:RemoveCard(c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,mg,c:GetOriginalLevel())
	Duel.SendtoGrave(g,REASON_COST)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.subspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<-1 then return end
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	local mg=Duel.GetReleaseGroup(tp,false,false,REASON_EFFECT):Filter(Card.IsLevelAbove,nil,1)
	if not mg:IsContains(c) then return end
	mg:RemoveCard(c)
	if #mg==0 then return end
	if tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_DEFENSE) then
		local lv=tc:GetLevel()-c:GetOriginalLevel()
		local g=Group.CreateGroup()
		if lv<=0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			g=mg:Select(tp,1,1,nil)
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			g=mg:SelectWithSumGreater(tp,Card.GetOriginalLevel,lv)
		end
		g:AddCard(c)
		if #g>=2 and Duel.Release(g,REASON_EFFECT)~=0 then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_DEFENSE)
		end
	end
end
function s.selfspconfilter(c,tp)
	return c:IsSetCard(SET_SUBTERROR_BEHEMOTH) and c:IsControler(tp)
end
function s.selfspcon(e,tp,eg,ep,ev,re,r,rp)
	return rp~=PLAYER_NONE and eg:IsExists(s.selfspconfilter,1,nil,tp)
end
function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.selfspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end