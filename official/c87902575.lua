--フューチャー・ヴィジョン
--Future Visions
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.clear)
	c:RegisterEffect(e1)
	local ng=Group.CreateGroup()
	ng:KeepAlive()
	e1:SetLabelObject(ng)
	--remove
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	--return
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e3:SetCountLimit(1)
	e3:SetCondition(s.retcon)
	e3:SetOperation(s.retop)
	e3:SetLabelObject(e1)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_PHASE_START|PHASE_MAIN1)
	e4:SetRange(LOCATION_FZONE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCountLimit(1)
	e4:SetOperation(s.clearop)
	e4:SetLabelObject(e1)
	c:RegisterEffect(e4)
end
function s.clear(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetLabelObject():Clear()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return eg:GetFirst():IsOnField()
		and eg:GetFirst():IsCanBeEffectTarget(e) end
	Duel.SetTargetCard(eg:GetFirst())
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tc=eg:GetFirst()
	if tc:IsRelateToEffect(e) and tc:IsLocation(LOCATION_MZONE) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT|REASON_TEMPORARY)~=0 then
		tc:CreateRelation(e:GetHandler(),RESET_EVENT|RESETS_STANDARD)
		e:GetLabelObject():GetLabelObject():AddCard(tc)
	end
end
function s.retfilter(c,ec,tp)
	return c:IsRelateToCard(ec) and c:IsPreviousControler(tp)
end
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject():GetLabelObject()
	return g:FilterCount(s.retfilter,nil,e:GetHandler(),Duel.GetTurnPlayer())>0
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local p=Duel.GetTurnPlayer()
	local lg=e:GetLabelObject():GetLabelObject()
	local g=lg:Filter(s.retfilter,nil,e:GetHandler(),p)
	lg:Sub(g)
	local ft=Duel.GetLocationCount(p,LOCATION_MZONE)
	if #g>ft then
		local sg=g
		Duel.Hint(HINT_SELECTMSG,p,aux.Stringid(id,2))
		g=g:Select(p,ft,ft,nil)
		sg:Sub(g)
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		Duel.ReturnToField(tc,POS_FACEUP_ATTACK)
	end
end
function s.clfilter(c,ec,tp)
	return (not c:IsRelateToCard(ec)) or c:IsPreviousControler(tp)
end
function s.clearop(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():GetLabelObject():Remove(s.clfilter,nil,e:GetHandler(),Duel.GetTurnPlayer())
end