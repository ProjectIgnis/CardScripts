--薄明の魔 レイラージュ
--Rayrage, the Twilight Fiend
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--If a Pendulum Monster(s) you control would be destroyed by an opponent's card effect, you can destroy this card instead of 1 of those Pendulum Monsters. You can only use this effect of "Rayrage, the Twilight Fiend" once per turn
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTarget(s.reptg)
	e1:SetOperation(s.repop)
	e1:SetValue(function(e,c) return c==e:GetLabelObject():GetFirst() end)
	c:RegisterEffect(e1)
	--If this card is in your hand: You can target 1 Pendulum Monster you control; place that Pendulum Monster in your Pendulum Zone (but it cannot activate its Pendulum Effects this turn), and if you do, Special Summon this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,{id,0})
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--(Quick Effect): You can Tribute this card, then target 1 card in your Pendulum Zone; it cannot be destroyed by your opponent's card effects this turn
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCost(Cost.SelfTribute)
	e3:SetTarget(s.efftg)
	e3:SetOperation(s.effop)
	c:RegisterEffect(e3)
end
function s.repfilter(c,tp,opp)
	return c:IsPendulumMonster() and c:IsControler(tp) and c:IsOnField() and c:IsReasonPlayer(opp)
		and c:IsFaceup() and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local opp=1-tp
	local c=e:GetHandler()
	if chk==0 then return not Duel.HasFlagEffect(tp,id) and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED) 
		and eg:IsExists(s.repfilter,1,nil,tp,opp) end
	if Duel.SelectEffectYesNo(tp,c,96) then
		Duel.Hint(HINT_CARD,0,id)
		local g=eg:Filter(s.repfilter,nil,tp,opp)
		if #g>1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
			g=g:Select(tp,1,1,nil)
			Duel.HintSelection(g)
		end
		e:SetLabelObject(g)
		c:SetStatus(STATUS_DESTROY_CONFIRMED,true)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		return true
	else return false end
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	Duel.Destroy(c,REASON_EFFECT|REASON_REPLACE)
end
function s.plfilter(c,tp)
	return c:IsPendulumMonster() and c:IsFaceup() and Duel.GetMZoneCount(tp,c)>0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.plfilter(chkc,tp) end
	local c=e:GetHandler()
	if chk==0 then return Duel.CheckPendulumZones(tp)
		and Duel.IsExistingTarget(s.plfilter,tp,LOCATION_MZONE,0,1,nil,tp)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	Duel.SelectTarget(tp,s.plfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e)
		and Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true) then
		local c=e:GetHandler()
		--It cannot activate its Pendulum Effects this turn
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
		if c:IsRelateToEffect(e) then
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_PZONE) end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_PZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_APPLYTO)
	Duel.SelectTarget(tp,nil,tp,LOCATION_PZONE,0,1,1,nil)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		--It cannot be destroyed by your opponent's card effects this turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3060)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetValue(aux.indoval)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
end