--六花深聖ティアドロップ
--Teardrop the Rikka Empress
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2 Level 10 Plant monsters, or 1 "Teardrop the Rikka Queen"
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_PLANT),10,2,s.altmatfilter,aux.Stringid(id,0))
	--(Quick Effect): You can detach up to 6 materials from this card; send that many Spells/Traps on the field to the GY, then you can Tribute 1 monster on the field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_RELEASE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.DetachFromSelf(1,s.tgcostmax))
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E|TIMING_SSET)
	c:RegisterEffect(e1)
	--Each time a monster(s) is Tributed: Attach 1 card from your opponent's GY to 1 Plant Xyz Monster you control
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_RELEASE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.attachcon)
	e2:SetTarget(s.attachtg)
	e2:SetOperation(s.attachop)
	c:RegisterEffect(e2)
end
s.listed_names={33779875} --"Teardrop the Rikka Queen"
function s.altmatfilter(c,tp,xyzc)
	return c:IsSummonCode(xyzc,SUMMON_TYPE_XYZ,tp,33779875) and c:IsFaceup()
end
function s.tgcostmax(e)
	local ct=Duel.GetMatchingGroupCount(aux.AND(Card.IsSpellTrap,Card.IsAbleToGrave),0,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	return math.min(ct,6)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,#e:GetChainData().cost_detached_materials,PLAYER_ALL,LOCATION_ONFIELD)
	Duel.SetPossibleOperationInfo(0,CATEGORY_RELEASE,nil,1,PLAYER_EITHER,LOCATION_MZONE)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local ct=#e:GetChainData().cost_detached_materials
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,aux.AND(Card.IsSpellTrap,Card.IsAbleToGrave),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,ct,nil)
	if #g~=ct then return end
	Duel.HintSelection(g)
	if Duel.SendtoGrave(g,REASON_EFFECT)==0 or not g:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE) then return end
	local rg=Duel.GetMatchingGroup(Card.IsReleasableByEffect,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #rg==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,3)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local srg=rg:Select(tp,1,1,nil)
	if #srg>0 then
		Duel.HintSelection(srg)
		Duel.BreakEffect()
		Duel.Release(srg,REASON_EFFECT)
	end
end
function s.attachconfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) or (c:IsMonsterCard() and not c:IsPreviousLocation(LOCATION_SZONE))
end
function s.attachcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.attachconfilter,1,nil)
end
function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,1-tp,LOCATION_GRAVE)
end
function s.attachfilter(c,e,tp)
	return not c:IsImmuneToEffect(e) and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil,c,e,tp)
end
function s.xyzfilter(c,mc,e,tp)
	return c:IsXyzMonster() and c:IsRace(RACE_PLANT) and c:IsFaceup()
		and not c:IsImmuneToEffect(e) and mc:IsCanBeXyzMaterial(c,tp,REASON_EFFECT)
end
function s.attachop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local mc=Duel.SelectMatchingCard(tp,s.attachfilter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp):GetFirst()
	if not mc then return end
	Duel.HintSelection(mc)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local xc=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil,mc,e,tp):GetFirst()
	if xc then
		Duel.HintSelection(xc)
		Duel.Overlay(xc,mc)
	end
end