--ハイパーブレイズ
--Hyper Blaze
--Scripted by Naim, procedure by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_ATTACK)
	c:RegisterEffect(e1)
	--Procedure enhancement
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(id)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e2)
	--atkup
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.atkcon)
	e3:SetCost(s.atkcost)
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
	--to hand or special summon from GY
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCountLimit(1)
	e4:SetCost(s.spcost)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
s.listed_names={6007213,32491822,69890967}
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	local dc=Duel.GetAttackTarget()
	if (tc:IsCode(6007213) and tc:IsControler(tp))
		then e:SetLabelObject(tc) return true
	elseif (dc and dc:IsCode(6007213) and dc:IsControler(tp))
		then e:SetLabelObject(dc) return true end
	return false
end
function s.atkcfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsAbleToGraveAsCost()
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.atkcfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=Duel.SelectMatchingCard(tp,s.atkcfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil):GetFirst()
	Duel.SendtoGrave(tc,REASON_COST)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(id)==0 end
	Duel.SetTargetCard(e:GetLabelObject())
	e:SetLabelObject(nil)
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
function s.atkfilter(c)
	return c:IsType(TYPE_TRAP) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(s.atkfilter,c:GetControler(),LOCATION_GRAVE+LOCATION_ONFIELD,LOCATION_GRAVE+LOCATION_ONFIELD,nil)*1000
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsRelateToBattle() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(s.atkval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		tc:RegisterEffect(e2)
	end
end
function s.atkcfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsAbleToGraveAsCost()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local tc=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
	Duel.SendtoGrave(tc,REASON_COST+REASON_DISCARD)
end
function s.filter(c,e,tp,ft)
	return c:IsCode(6007213,32491822,69890967) and (c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,true,false)))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,ft) and e:GetHandler():GetFlagEffect(id+1)==0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	e:GetHandler():RegisterFlagEffect(id+1,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local hc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,ft):GetFirst()
	if hc then
		aux.ToHandOrElse(hc,tp,s.spcheck(e,tp),s.spop2(tp),aux.Stringid(id,2))
	end
end
function s.spcheck(e,tp)
	return	function(c)
				return c:IsCanBeSpecialSummoned(e,0,tp,true,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			end
end
function s.spop2(tp)
	return	function(c)
				return Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
			end
end
