--パーティカル・フュージョン
--Particle Fusion
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	c:RegisterEffect(Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsSetCard,0x1047),Fusion.OnFieldMat,nil,nil,nil,s.stage2))
	--atk up
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_CUSTOM+id)
	e2:SetCost(s.atkcost)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
s.listed_series={0x1047}
function s.stage2(e,tc,tp,sg,chk)
	if chk==1 then
		e:SetLabelObject(tc)
		Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+id,e,0,tp,tp,0)
	end
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsAbleToRemove() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tc=e:GetLabelObject():GetLabelObject()
	local mat=tc:GetMaterial()
	if chkc then return chkc:IsSetCard(0x1047) and mat:IsContains(chkc) end
	if chk==0 then return mat:IsExists(Card.IsSetCard,1,nil,0x1047) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local g=mat:FilterSelect(tp,Card.IsSetCard,1,1,nil,0x1047)
	tc:CreateEffectRelation(e)
	Duel.SetTargetCard(g)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp,chk)
	local sc=e:GetLabelObject():GetLabelObject()
	if not sc:IsRelateToEffect(e) or sc:IsFacedown() then return end
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(tc:GetAttack())
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	sc:RegisterEffect(e1)
end
