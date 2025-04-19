--チャージ・フュージョン
--Fusion Charge
--rescripted by Naim to match the Fusion Summon procedure
local s,id=GetID()
function s.initial_effect(c)
	local e1=Fusion.CreateSummonEff({handler=c,matfilter=Fusion.InHandMat,stage2=s.stage2})
	c:RegisterEffect(e1)
end
function s.stage2(e,tc,tp,sg,chk)
	if chk==1 and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		local res=0
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetCategory(CATEGORY_TOHAND)
		e1:SetType(EFFECT_TYPE_IGNITION)
		e1:SetRange(LOCATION_GRAVE)
		if Duel.IsTurnPlayer(tp) then
			res=3
			e1:SetLabel(Duel.GetTurnCount())
		else
			res=2
			e1:SetLabel(Duel.GetTurnCount()-1)
		end
		e1:SetValue(4)
		e1:SetCondition(s.thcon)
		e1:SetTarget(s.thtg)
		e1:SetOperation(s.thop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_EXC_GRAVE+RESET_PHASE+PHASE_END+RESET_SELF_TURN,res)
		c:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
		e2:SetCode(1082946)
		e2:SetLabelObject(e1)
		e2:SetOperation(s.reset)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD_EXC_GRAVE+RESET_PHASE+PHASE_END+RESET_SELF_TURN,res)
		c:RegisterEffect(e2)
	end
end
function s.reset(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	local val=te:GetValue()
	if Duel.GetTurnCount()==te:GetLabel()+val then
		e:GetHandler():SetTurnCounter(3)
		e:Reset() te:Reset()
	else
		val=val-2
		if Duel.GetTurnCount()==te:GetLabel()+val then
			e:GetHandler():SetTurnCounter(2)
		elseif Duel.GetTurnCount()==te:GetLabel()+val-2 then
			e:GetHandler():SetTurnCounter(1)
		end
		te:SetValue(val)
	end
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnCount()==e:GetLabel()+e:GetValue()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c)
	end
end