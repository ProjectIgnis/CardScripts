--メタル化・強化反射装甲
--Max Metalmorph
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 monster that cannot be Normal Summoned/Set and mentions "Max Metalmorph" from your hand/Deck/GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMING_BATTLE_START|TIMINGS_CHECK_MONSTER_E)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_MAX_METALMORPH}
function s.costfilter(c,e,tp)
	return c:IsFaceup() and Duel.GetMZoneCount(tp,c)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp,c:GetLevel(),c:GetRace())
end
function s.spfilter(c,e,tp,cost_lv,cost_race)
	if not (c:IsMonster() and not c:IsSummonableCard() and c:ListsCode(CARD_MAX_METALMORPH)) then return false end
	if c:IsCanBeSpecialSummoned(e,0,tp,false,false) or c.max_metalmorph_stats==nil then return true end
	if not (c:IsCanBeSpecialSummoned(e,0,tp,true,true) and cost_lv and cost_race) then return false end
	local lv,race=table.unpack(c.max_metalmorph_stats)
	return cost_lv>=lv and cost_race&race>0
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local res=Duel.CheckReleaseGroupCost(tp,s.costfilter,1,false,nil,nil,e,tp)
		if res then e:SetLabel(1) end
		return res
	end
	local rc=Duel.SelectReleaseGroupCost(tp,s.costfilter,1,1,false,nil,nil,e,tp):GetFirst()
	e:SetLabel(rc:GetLevel(),rc:GetRace())
	Duel.Release(rc,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local res=e:GetLabel()==1 or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp))
		e:SetLabel(0)
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	local cost_lv,cost_race=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp,cost_lv,cost_race):GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)>0 then
		tc:CompleteProcedure()
		if not (c:IsRelateToEffect(e) and Duel.SelectYesNo(tp,aux.Stringid(id,1))) then return end
		c:CancelToGrave(true)
		Duel.BreakEffect()
		if not tc:EquipByEffectAndLimitRegister(e,tp,c,nil,true) then return end
		--Equip limit
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_SINGLE)
		e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e0:SetCode(EFFECT_EQUIP_LIMIT)
		e0:SetValue(function(e,c) return c==tc end)
		e0:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e0)
		--The equipped monster gains 400 ATK/DEF
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(400)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)
		--The equipped monster cannot be destroyed by monster and Spell effects
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_EQUIP)
		e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e3:SetValue(function(e,re,rc,c) return re:IsMonsterEffect() or re:IsSpellEffect() end)
		e3:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e3)
		--Your opponent cannot target the monster with monster and Spell effects
		local e4=e3:Clone()
		e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e4:SetValue(function(e,re,rp) return rp==1-e:GetHandlerPlayer() and (re:IsMonsterEffect() or re:IsSpellEffect()) end)
		c:RegisterEffect(e4)
	end
end