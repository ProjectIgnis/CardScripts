--Japanese name
--The Undying Legion
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2 Level 7 monsters, OR 1 Rank 6 Zombie Xyz Monster you control
	Xyz.AddProcedure(c,nil,7,2,s.ovfilter,aux.Stringid(id,0),2,s.xyzop)
	--During your opponent's Main Phase (Quick Effect): You can detach 2 materials from this card (or just 1 material if all this card's materials are Xyz Monsters), then target 1 Attack Position monster your opponent controls or 1 monster in their GY; attach it to this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e,tp) return Duel.IsMainPhase(1-tp) end)
	e1:SetCost(Cost.DetachFromSelf(s.attachcostmin,2))
	e1:SetTarget(s.attachtg)
	e1:SetOperation(s.attachop)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e1)
end
s.listed_names={id}
function s.ovfilter(c,tp,xyzc)
	return c:IsRank(6) and c:IsRace(RACE_ZOMBIE,xyzc,SUMMON_TYPE_XYZ,tp) and c:IsXyzMonster() and c:IsFaceup()
end
function s.xyzop(e,tp,chk)
	if chk==0 then return not Duel.HasFlagEffect(tp,id) end
	return Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,EFFECT_FLAG_OATH,1)
end
function s.attachcostmin(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetHandler():GetOverlayGroup()
	return #g==g:FilterCount(Card.IsXyzMonster,nil) and 1 or 2
end
function s.attachfilter(c,xyzc,tp)
	return c:IsAttackPos() and c:IsMonster() and c:IsCanBeXyzMaterial(xyzc,tp,REASON_EFFECT)
end
function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE|LOCATION_GRAVE) and s.attachfilter(chkc,c,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.attachfilter,tp,0,LOCATION_MZONE|LOCATION_GRAVE,1,nil,c,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.attachfilter,tp,0,LOCATION_MZONE|LOCATION_GRAVE,1,1,nil,c,tp)
	if c:IsLocation(LOCATION_GRAVE) then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,tp,0)
	end
end
function s.attachop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		Duel.Overlay(c,tc,true)
	end
end