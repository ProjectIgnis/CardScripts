--プレデション（予言）
--Prediction 
--original script by Shad3
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Predict
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.cont_cd)
	e2:SetOperation(s.cont_op)
	c:RegisterEffect(e2)
	--Negate Prediction
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.neg_cd)
	e3:SetOperation(s.neg_op)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SUMMON)
	e4:SetCondition(s.neg1_cd)
	e4:SetOperation(s.negs_op)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_FLIP_SUMMON)
	e5:SetCondition(s.neg2_cd)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EVENT_SPSUMMON)
	e6:SetCondition(s.neg3_cd)
	c:RegisterEffect(e6)
	c:RegisterFlagEffect(id,0,0,0)
	--Reset Prediction
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_TURN_END)
	e7:SetRange(LOCATION_SZONE)
	e7:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e7:SetCountLimit(1)
	e7:SetOperation(s.rst_op)
	c:RegisterEffect(e7)
end
function s.cont_cd(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end
function s.cont_op(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local cde=Duel.AnnounceCard(tp)
	local act=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2),aux.Stringid(id,3))
	e:SetLabel(act)
	e:GetHandler():SetFlagEffectLabel(id,cde)
end
function s.neg_cd(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and e:GetLabelObject():GetLabel()==0 and re:GetHandler():IsCode(e:GetHandler():GetFlagEffectLabel(id)) and Duel.IsChainNegatable(ev)
end
function s.neg_op(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
end
function s.neg1_cd(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and Duel.GetCurrentChain()==0 and e:GetLabelObject():GetLabel()==1 and eg:IsExists(Card.IsCode,1,nil,e:GetHandler():GetFlagEffectLabel(id))
end
function s.neg2_cd(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and Duel.GetCurrentChain()==0 and e:GetLabelObject():GetLabel()==2 and eg:IsExists(Card.IsCode,1,nil,e:GetHandler():GetFlagEffectLabel(id))
end
function s.neg3_cd(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and Duel.GetCurrentChain()==0 and e:GetLabelObject():GetLabel()==3 and eg:IsExists(Card.IsCode,1,nil,e:GetHandler():GetFlagEffectLabel(id))
end
function s.negs_op(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateSummon(eg)
end
function s.rst_op(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():SetFlagEffectLabel(id,0)
end