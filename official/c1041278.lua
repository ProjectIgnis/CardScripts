-- 分かつ烙印
-- Branded Expulsion
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Special Summon 2 non-Fusion monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_ALBAZ}
function s.spfilter(c,e,tp,targetp)
	return c:IsFaceup() and not c:IsType(TYPE_FUSION)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,targetp) and c:IsCanBeEffectTarget(e)
end
function s.spcostfilter(c,tp,b1,b2)
	local ft=Duel.GetMZoneCount(tp,c)
	return ft>0 and c:IsType(TYPE_FUSION) and ((b1 and Duel.GetMZoneCount(1-tp,c)>0)
		or (b2 and ft>1 and c:ListsCodeAsMaterial(CARD_ALBAZ)))
end
function s.rescon(ag,g1,g2)
	return function(sg,e,tp,mg)
		local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
		local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
		local res1=ft1>=2 and #(ag&sg)>=2
		local res2=ft1>0 and ft2>0 and #(sg&g1)>0 and #(sg&g2)>0
		return res1 or res2,not (res1 or res2)
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return false end
	local g1=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,nil,e,tp,tp)
	local g2=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,nil,e,tp,1-tp)
	local b1=(#g1>1 and #g2>1) or (#(g1&g2)~=#g1 and #(g1&g2)~=#g2)
	local ag=g1:Filter(Card.IsCanBeSpecialSummoned,nil,e,0,tp,false,false,POS_FACEUP_DEFENSE)
	local b2=#ag>1
	if chk==0 then return (b1 or b2) and Duel.CheckReleaseGroupCost(tp,s.spcostfilter,1,false,nil,nil,tp,b1,b2) end
	local rc=Duel.SelectReleaseGroupCost(tp,s.spcostfilter,1,1,false,nil,nil,tp,b1,b2):GetFirst()
	local albaz=rc:ListsCodeAsMaterial(CARD_ALBAZ)
	Duel.Release(rc,REASON_COST)
	local tg=nil
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	b1=b1 and ft1>0 and ft2>0
	b2=b2 and ft1>=2
	if b1 and not b2 then
		tg=aux.SelectUnselectGroup(g1+g2,e,tp,2,2,function(sg) return #(sg&g1)>0 and #(sg&g2)>0 end,1,tp,HINTMSG_SPSUMMON)
	elseif not b1 and b2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		tg=ag:Select(tp,2,2,nil)
	else
		if not albaz then
			tg=aux.SelectUnselectGroup(g1+g2,e,tp,2,2,function(sg) return #(sg&g1)>0 and #(sg&g2)>0 end,1,tp,HINTMSG_SPSUMMON)
		else
			tg=aux.SelectUnselectGroup(g1+g2,e,tp,2,2,s.rescon(ag,g1,g2),1,tp,HINTMSG_SPSUMMON)
		end
	end
	if tg and #tg==2 then
		Duel.SetTargetCard(tg)
		e:SetLabel(albaz and 100 or 0)
	end
	local locations=tg:GetBitwiseOr(Card.GetLocation)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg,#tg,0,locations)
end
function s.spownfilter(c,e,tp,tg)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (tg-c):GetFirst():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if #tg<2 or ft1<1 or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	local b1=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and tg:IsExists(s.spownfilter,1,nil,e,tp,tg)
	local b2=ft1>1 and e:GetLabel()==100
		and tg:FilterCount(Card.IsCanBeSpecialSummoned,nil,e,0,tp,false,false,POS_FACEUP_DEFENSE)==2
	if b2 and (not b1 or Duel.SelectYesNo(tp,aux.Stringid(id,1))) then
		Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	elseif b1 then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
		local sc=tg:FilterSelect(tp,s.spownfilter,1,1,nil,e,tp,tg):GetFirst()
		if not sc then return end
		Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP)
		Duel.SpecialSummonStep((tg-sc):GetFirst(),0,tp,1-tp,false,false,POS_FACEUP)
		Duel.SpecialSummonComplete()
	end
end
