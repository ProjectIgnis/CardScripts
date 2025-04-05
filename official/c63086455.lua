--現世離レ
--Terrors of the Overroot
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Send 1 card to the GY and Set 1 card from the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E|TIMING_MAIN_END)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
end
function s.tgfilter(c,e)
	return c:IsAbleToGrave() and c:IsCanBeEffectTarget(e)
end
function s.setfilter(c,e,tp)
	return c:IsCanBeEffectTarget(e) and ((c:IsSpellTrap() and c:IsSSetable(true))
		or c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,1-tp))
end
function s.rescon(sg,e,tp)
	local g1,g2=sg:Split(Card.IsOnField,nil)
	if #g1~=1 or #g2~=1 then return end
	local c1,c2=g1:GetFirst(),g2:GetFirst()
	if c2:IsMonster() then return Duel.GetMZoneCount(1-tp,c1)>0 end
	return (c2:IsSpell() and c2:IsType(TYPE_FIELD))
		or Duel.GetLocationCount(1-tp,LOCATION_SZONE)>0
		or (c1:IsLocation(LOCATION_SZONE) and c1:GetSequence()<5 --[[and check if exc's zone is not disabled]])
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g1=Duel.GetMatchingGroup(s.tgfilter,tp,0,LOCATION_ONFIELD,nil,e)
	local g2=Duel.GetMatchingGroup(s.setfilter,tp,0,LOCATION_GRAVE,nil,e,tp)
	if chk==0 then return #g1>0 and #g2>0 and aux.SelectUnselectGroup(g1+g2,e,tp,2,2,s.rescon,0) end
	local tg=aux.SelectUnselectGroup(g1+g2,e,tp,2,2,s.rescon,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(tg)
	g1,g2=tg:Split(Card.IsOnField,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g1,1,0,0)
	local cat=e:GetCategory()
	if g2:GetFirst():IsMonster() then
		e:SetCategory(cat|CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g2,1,0,0)
	else
		e:SetCategory(cat&~CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g2,1,0,0)
	end
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg==0 then return end
	local g1,g2=tg:Split(Card.IsOnField,nil)
	if #g1>0 and Duel.SendtoGrave(g1,REASON_EFFECT)>0 and g1:GetFirst():IsLocation(LOCATION_GRAVE) then
		local sc=g2:GetFirst()
		if not sc then return end
		if sc:IsMonster() and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
			and Duel.SpecialSummon(sc,0,tp,1-tp,false,false,POS_FACEDOWN_DEFENSE)>0 then
			Duel.ConfirmCards(1-tp,sc)
		elseif sc:IsSpellTrap() and sc:IsSSetable() then
			Duel.SSet(tp,sc,1-tp)
		end
	end
end