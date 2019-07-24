--TG レシプロ・ドラゴン・フライ
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,1)
	c:EnableReviveLimit()
	--todeck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95100034,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	--Type Machine
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_ADD_RACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(RACE_MACHINE)
	c:RegisterEffect(e3)
	--draw
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_PLAYER_TARGET)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetTarget(s.drtg)
	e4:SetOperation(s.drop)
	c:RegisterEffect(e4)
	--Half stats
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(95100034,4))
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.discon)
	e5:SetOperation(s.disop)
	c:RegisterEffect(e5)
end
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and (c:IsAbleToGrave() or c:IsAbleToExtra())
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc:IsAbleToExtra() then
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	end
	if tc:IsAbleToGrave() then
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	end
end
function s.mgfilter(c,e,tp,sync)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE)
		and c:GetReason()&0x80008==0x80008 and c:GetReasonCard()==sync
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	local a=tc:IsAbleToGrave()
	local b=tc:IsAbleToExtra()
	local op=2
	if a and b then
		op=Duel.SelectOption(tp,aux.Stringid(2407147,0),aux.Stringid(52823314,0))
	elseif a then
		Duel.SelectOption(tp,aux.Stringid(2407147,0))
		op=0
	elseif b then
		Duel.SelectOption(tp,aux.Stringid(52823314,0))
		op=1
	end
	local mg=tc:GetMaterial()
	local sumtype=tc:GetSummonType()
	local sumable=false
	if op==0 and Duel.SendtoGrave(tc,REASON_EFFECT)>0 then sumable=true end
	if op==1 and Duel.SendtoDeck(tc,nil,0,REASON_EFFECT)>0 then sumable=true end
	if sumable and sumtype==SUMMON_TYPE_SYNCHRO and #mg>0 or #mg<=Duel.GetLocationCount(tp,LOCATION_MZONE)
		and mg:FilterCount(aux.NecroValleyFilter(s.mgfilter),nil,e,tp,tc)==#mg and Duel.SelectYesNo(tp,aux.Stringid(32441317,0)) then
		Duel.BreakEffect()
		Duel.SpecialSummon(mg,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) or not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	return re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS):IsContains(c)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c:GetBaseAttack()/2)
		c:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_SET_BASE_DEFENSE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(c:GetBaseDefense()/2)
		c:RegisterEffect(e2)
	end
end
