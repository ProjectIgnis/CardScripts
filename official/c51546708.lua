--ＤＴナイトメア・ハンド
--Dark Tuner Nightmare Hand
--Scripted by the Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--You can reveal this card in your hand; immediately after this effect resolves, Normal Summon 1 "Dark Tuner" monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.SelfReveal)
	e1:SetTarget(s.nstg)
	e1:SetOperation(s.nsop)
	c:RegisterEffect(e1)
	--If this card is Normal Summoned: You can Special Summon 1 Level 2 or lower monster from your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--Once per turn, if you control this Normal Summoned/Set card: You can Tribute both this face-up card and 1 face-up non-Tuner with a lower Level, and if you do, Special Summon 1 Synchro Monster from your Extra Deck with a Level equal to the difference in Levels of those monsters (this is treated as a Synchro Summon)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(function(e) return e:GetHandler():IsNormalSummoned() end)
	e3:SetTarget(s.darksynchtg)
	e3:SetOperation(s.darksynchop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_DARK_TUNER}
function s.nsfilter(c)
	return c:IsSetCard(SET_DARK_TUNER) and c:IsSummonable(true,nil)
end
function s.nstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.nsfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_MZONE)
end
function s.nsop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.nsfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil):GetFirst()
	if sc then
		Duel.Summon(tp,sc,true,nil)
	end
end
function s.spfilter(c,e,tp)
	return c:IsLevelBelow(2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.nontunerfilter(c,e,tp,lv,mc)
	return not c:IsType(TYPE_TUNER) and c:IsReleasable() and c:IsFaceup() and c:HasLevel() and c:IsLevelBelow(lv-1)
		and Duel.IsExistingMatchingCard(s.darksyncfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,lv-c:GetLevel(),Group.FromCards(c,mc))
end
function s.darksyncfilter(c,e,tp,lv,mg)
	return c:IsSynchroMonster() and c:IsLevel(lv) and Duel.GetLocationCountFromEx(tp,tp,mg,c)>0
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end
function s.darksynchtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,nil,nil,REASON_SYNCHRO)
		return #pg<=0 and c:IsReleasable() and Duel.IsExistingMatchingCard(s.nontunerfilter,tp,LOCATION_MZONE,0,1,c,e,tp,c:GetLevel(),c)
	end
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,c,2,tp,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.darksynchop(e,tp,eg,ep,ev,re,r,rp)
	local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,nil,nil,REASON_SYNCHRO)
	if #pg>0 then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local lv=c:GetLevel()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local sc=Duel.SelectMatchingCard(tp,s.nontunerfilter,tp,LOCATION_MZONE,0,1,1,c,e,tp,lv,c):GetFirst()
		if not sc then return end
		Duel.HintSelection(sc)
		lv=lv-sc:GetLevel()
		if Duel.Release(Group.FromCards(c,sc),REASON_EFFECT)==2 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sync=Duel.SelectMatchingCard(tp,s.darksyncfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,lv):GetFirst()
			if sync and Duel.SpecialSummon(sync,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
				sync:CompleteProcedure()
			end
		end
	end
end