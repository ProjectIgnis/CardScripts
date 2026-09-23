--太陽神の支配
--Sun God Domination
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--If a "The Winged Dragon of Ra" monster is on the field: Apply these effects in sequence
	--● Special Summon 1 monster from each GY to your field
	--● If "The Winged Dragon of Ra" is on the field, take control of all monsters your opponent controls
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--You can banish this card from your GY and Tribute 1 "The Winged Dragon of Ra" monster; gain LP equal to the ATK it had on the field
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.AND(Cost.SelfBanish,s.lpgaincost))
	e2:SetTarget(s.lpgaintg)
	e2:SetOperation(s.lpgainop)
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_RA}
s.listed_series={SET_THE_WINGED_DRAGON_OF_RA}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_THE_WINGED_DRAGON_OF_RA),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,nil)
	if chk==0 then
		--● Special Summon 1 monster from each GY to your field
		local sp_eff_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>=2
			and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
			and Duel.IsExistingMatchingCard(s.spfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp)
		--● If "The Winged Dragon of Ra" is on the field, take control of all monsters your opponent controls
		local ctrl_eff_chk=#g>0 and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_RA),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
			and Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_CONTROL)>=#g
		return sp_eff_chk or ctrl_eff_chk
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,PLAYER_ALL,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_CONTROL,g,#g,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local break_chk=false
	--● Special Summon 1 monster from each GY to your field
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>=2 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp)
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,0,LOCATION_GRAVE,1,nil,e,tp) then
		local gyg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e,tp)
		local sg=aux.SelectUnselectGroup(gyg,e,tp,2,2,aux.dpcheck(Card.GetControler),1,tp,HINTMSG_SPSUMMON)
		if #sg==2 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
		break_chk=true
	end
	--● If "The Winged Dragon of Ra" is on the field, take control of all monsters your opponent controls
	local ctrlg=Duel.GetMatchingGroup(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,nil)
	if #ctrlg>0 and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_RA),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) then
		if break_chk then Duel.BreakEffect() end
		Duel.GetControl(ctrlg,tp)
	end
end
function s.lpgaincostfilter(c)
	return c:IsSetCard(SET_THE_WINGED_DRAGON_OF_RA) and c:GetAttack()>0
end
function s.lpgaincost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(-1)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.lpgaincostfilter,1,false,nil,nil) end
	local sc=Duel.SelectReleaseGroupCost(tp,s.lpgaincostfilter,1,1,false,nil,nil):GetFirst()
	e:GetChainData().atk=sc:GetAttack()
	Duel.Release(sc,REASON_COST)
end
function s.lpgaintg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local cost_chk=e:GetLabel()==-1
		e:SetLabel(0)
		return cost_chk
	end
	local lp=e:GetChainData().atk
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(lp)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,1,tp,lp)
end
function s.lpgainop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Recover(p,d,REASON_EFFECT)
end