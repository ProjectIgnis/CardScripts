--守護天霊ロガエス
--Protecting Spirit Loagaeth
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Apply a "it cannot be destroyed by battle this turn" effect on 1 monster on the field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and r&(REASON_BATTLE|REASON_EFFECT)>0 end)
	e1:SetTarget(s.indestg)
	e1:SetOperation(s.indesop)
	c:RegisterEffect(e1)
	--Special Summon this card from your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--Banish 1 face-up card your opponent controls and change 1 Attack Position monster you control to Defense Position
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
end
function s.indestg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingTarget(aux.NOT(Card.IsHasEffect),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,EFFECT_INDESTRUCTABLE_BATTLE) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_APPLYTO)
	Duel.SelectTarget(tp,aux.NOT(Card.IsHasEffect),tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,EFFECT_INDESTRUCTABLE_BATTLE)
end
function s.indesop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		--It cannot be destroyed by battle this turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3000)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local trig_race,trig_loc,trig_ctrl=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_RACE,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_CONTROLER)
	return trig_race and trig_race&RACE_FAIRY>0 and trig_loc==LOCATION_MZONE and trig_ctrl==tp
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then 
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.tgfilter(c,e,tp)
	return ((c:IsControler(1-tp) and c:IsAbleToRemove() and c:IsFaceup())
		or (c:IsControler(tp) and c:IsAttackPos() and c:IsCanChangePosition()))
		and c:IsCanBeEffectTarget(e)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_MZONE,LOCATION_ONFIELD,nil,e,tp)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,2,aux.dpcheck(Card.GetControler),0) end
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dpcheck(Card.GetControler),1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(tg)
	local rmg,posg=tg:Split(Card.IsControler,nil,1-tp)
	e:SetLabelObject(rmg:GetFirst())
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rmg,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,posg,1,tp,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg==0 then return end
	local rm_tc=e:GetLabelObject()
	if rm_tc:IsRelateToEffect(e) and rm_tc:IsControler(1-tp) and Duel.Remove(rm_tc,POS_FACEUP,REASON_EFFECT)>0
		and rm_tc:IsLocation(LOCATION_REMOVED) then
		local pos_tc=(tg-rm_tc):GetFirst()
		if pos_tc and pos_tc:IsRelateToEffect(e) and pos_tc:IsControler(tp) then
			Duel.ChangePosition(pos_tc,POS_FACEUP_DEFENSE)
		end
	end
end