--Ｆ・ＨＥＲＯ フレイム・ウィングマン
--Favorite HERO Flame Wingman
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: 2 monsters with the same Type but different Attributes
	Fusion.AddProcMixN(c,true,true,s.matfilter,2)
	--When an attack is declared involving this card and a monster with 2200 or more ATK: You can make this card gain 1000 ATK, then you can Special Summon 1 Level 4 or lower monster from your hand in Defense Position
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.atkspcon)
	e1:SetTarget(s.atksptg)
	e1:SetOperation(s.atkspop)
	e1:SetCountLimit(1,{id,0})
	c:RegisterEffect(e1)
	--If a monster(s) was destroyed by battle this turn (Quick Effect): You can Fusion Summon 1 Fusion Monster from your Extra Deck, using monsters from your hand or field
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(function() return Duel.HasFlagEffect(0,id) end)
	e2:SetTarget(Fusion.SummonEffTG())
	e2:SetOperation(Fusion.SummonEffOP())
	e2:SetCountLimit(1,{id,1})
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMING_BATTLE_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e2)
	--Keep track of a monster being destroyed by battle
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLE_DESTROYED)
		ge1:SetOperation(function() Duel.RegisterFlagEffect(0,id,RESET_PHASE|PHASE_END,0,1) end)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_series={SET_ELEMENTAL_HERO}
function s.matfilter(c,fc,sumtype,sp,sub,mg,sg)
	return not sg or sg:FilterCount(aux.TRUE,c)==0 or (sg:IsExists(Card.IsRace,1,c,c:GetRace(),fc,sumtype,sp) and not sg:IsExists(Card.IsAttribute,1,c,c:GetAttribute(),fc,sumtype,sp))
end
function s.atkspcon(e,tp,eg,ep,ev,re,r,rp)
	local bc0,bc1=Duel.GetBattleMonster(tp)
	return bc0 and bc1 and bc0==e:GetHandler() and bc1:IsAttackAbove(2200) and bc1:IsFaceup()
end
function s.atksptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,tp,1000)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.atkspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() and c:UpdateAttack(1000)>0
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.BreakEffect()
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end