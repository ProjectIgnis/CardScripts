--マッド・プロファイラー
--Mad Profiler
local s,id=GetID()
function s.initial_effect(c)
	--You can Tribute 3 monsters to Special Summon this card from your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(83965310,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--If you do, it gains the following effect: You can send 1 card from your hand to the Graveyard to select 1 card on the field of the same type, and remove it from play.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(function(e) return e:GetHandler():HasFlagEffect(id) end)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
end
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.CheckReleaseGroup(c:GetControler(),aux.TRUE,3,false,3,true,c,c:GetControler(),nil,false,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.SelectReleaseGroup(tp,aux.TRUE,3,3,false,true,true,c,nil,nil,false,nil)
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
	return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Release(g,REASON_COST)
	g:DeleteGroup()
	c:RegisterFlagEffect(id,(RESET_EVENT|RESETS_STANDARD)&~RESET_TOFIELD,0,1)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(s.bancost)
	e1:SetTarget(s.bantg)
	e1:SetOperation(s.banop)
	c:RegisterEffect(e1)
end
function s.bancostfilter(c,tp)
	local tpe=0
	if c:IsMonster() then tpe=tpe|TYPE_MONSTER end
	if c:IsSpell() then tpe=tpe|TYPE_SPELL end
	if c:IsTrap() then tpe=tpe|TYPE_TRAP end
	return c:IsAbleToGraveAsCost() and Duel.IsExistingTarget(s.banfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,tpe)
end
function s.banfilter(c,tpe)
	return c:IsType(tpe) and c:IsAbleToRemove() and (c:IsFaceup() or tpe&TYPE_MONSTER>0)
end
function s.bancost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.bancostfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=Duel.SelectMatchingCard(tp,s.bancostfilter,tp,LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	Duel.SendtoGrave(tc,REASON_COST)
	local tpe=0
	if tc:IsMonster() then tpe=tpe|TYPE_MONSTER end
	if tc:IsSpell() then tpe=tpe|TYPE_SPELL end
	if tc:IsTrap() then tpe=tpe|TYPE_TRAP end
	e:SetLabel(tpe)
end
function s.bantg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.banfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,e:GetLabel())
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,0)
end
function s.banop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
