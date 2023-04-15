--トランザクション・ロールバック
--Transaction Rollback
local s,id=GetID()
function s.initial_effect(c)
	--Copy opponent's trap
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DRAW_PHASE+TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	e1:SetLabel(0)
	c:RegisterEffect(e1)
	--Copy your trap
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetLabel(1)
	c:RegisterEffect(e2)
end
s.listed_names={id}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local gy_check=true
	local c=e:GetHandler()
	if e:GetLabel()==1 then gy_check=c:IsAbleToRemoveAsCost() end
	if chk==0 then return gy_check end
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
	if e:GetLabel()==1 then Duel.Remove(c,POS_FACEUP,REASON_COST) end
end
function s.tgfilter(c)
	return c:IsNormalTrap() and not c:IsCode(id) and c:CheckActivateEffect(false,true,false)~=nil
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		local tg=te:GetTarget()
		return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	local loc1,loc2=0,0
	if e:GetLabel()==0 then loc2=LOCATION_GRAVE
	elseif e:GetLabel()==1 then loc1=LOCATION_GRAVE end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,loc1,loc2,1,e:GetHandler()) end
	e:SetProperty(EFFECT_FLAG_CARD_TARGET)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,loc1,loc2,1,1,e:GetHandler())
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(false,true,true)
	Duel.ClearTargetCard()
	g:GetFirst():CreateEffectRelation(e)
	local tg=te:GetTarget()
	e:SetProperty(te:GetProperty())
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	s[Duel.GetCurrentChain()]={ceg,cep,cev,cre,cr,crp}
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te or not te:GetHandler():IsRelateToEffect(e) then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,table.unpack(s[Duel.GetCurrentChain()])) end
end