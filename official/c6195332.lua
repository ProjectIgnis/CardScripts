--超神星輝士 セイクリッド・トレミスΩ７
--Exstellarknight Constellar Ptolemy Ω7
--Scripted by ahtelel
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 3 Level 7 monsters OR 1 "tellarknight" or "Constellar" Xyz Monster you control
	Xyz.AddProcedure(c,nil,7,3,s.ovfilter,aux.Stringid(id,0),3,s.xyzop)
	--While you have 7 or more "tellarknight" monsters with different names in your GY and/or banishment, this card gains 2700 ATK/DEF, also it is unaffected by your opponent's activated effects
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_SINGLE)
	e1a:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1a:SetCode(EFFECT_UPDATE_ATTACK)
	e1a:SetRange(LOCATION_MZONE)
	e1a:SetCondition(s.atkdefimmcon)
	e1a:SetValue(2700)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1b)
	local e1c=e1a:Clone()
	e1c:SetCode(EFFECT_IMMUNE_EFFECT)
	e1c:SetValue(function(e,te) return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActivated() end)
	c:RegisterEffect(e1c)
	--Shuffle opponent's monsters into the deck based on the number of materials you detach from this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(Cost.DetachFromSelf(1,function(e,tp) return Duel.GetTargetCount(Card.IsAbleToDeck,tp,0,LOCATION_MZONE,nil) end,function(e,og) e:SetLabel(#og) end))
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e2)
end
s.listed_series={SET_TELLARKNIGHT,SET_CONSTELLAR}
s.listed_names={id}
function s.ovfilter(c,tp,xyzc)
	return c:IsSetCard({SET_TELLARKNIGHT,SET_CONSTELLAR},xyzc,SUMMON_TYPE_XYZ,tp) and c:IsType(TYPE_XYZ,xyzc,SUMMON_TYPE_XYZ,tp) and c:IsFaceup()
end
function s.xyzop(e,tp,chk)
	if chk==0 then return Duel.IsMainPhase2(tp) and not Duel.HasFlagEffect(tp,id) end
	return Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,EFFECT_FLAG_OATH,1)
end
function s.atkdefimmfilter(c)
	return c:IsSetCard(SET_TELLARKNIGHT) and c:IsMonster() and c:IsFaceup()
end
function s.atkdefimmcon(e,c)
	return Duel.GetMatchingGroup(s.atkdefimmfilter,e:GetHandlerPlayer(),LOCATION_GRAVE|LOCATION_REMOVED,0,nil):GetClassCount(Card.GetCode)>=7
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToDeck() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_MZONE,1,nil) end
	local ct=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_MZONE,ct,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,tp,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end