--マグネット・フォース (Anime)
--Magnet Force (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
	--Remain field
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_REMAIN_FIELD)
	c:RegisterEffect(e2)
	--Redirect
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.redirectCon)
	e3:SetTarget(s.redirectTg)
	e3:SetOperation(s.redirectOp)
	c:RegisterEffect(e3)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsHasType(EFFECT_TYPE_ACTIVATE) end
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_TURN_END)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_SZONE)
	e1:SetOperation(function() Duel.SendtoGrave(c,REASON_RULE) end)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
	c:RegisterEffect(e1)
	local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(EVENT_CHAINING,true)
	if res and s.redirectCon(e,tp,teg,tep,tev,tre,tr,trp) and s.redirectTg(e,tp,teg,tep,tev,tre,tr,trp,0)
		and Duel.SelectEffectYesNo(tp,c) then
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		s.redirectTg(e,tp,teg,tep,tev,tre,tr,trp,1)
		e:SetOperation(s.redirectOp)
	else
		e:SetProperty(0)
		e:SetOperation(nil)
	end
end
function s.filter(c,p)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE+RACE_ROCK) and c:IsControler(p) and c:IsLocation(LOCATION_MZONE)
end
function s.redirectCon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g:IsExists(s.filter,1,nil,tp)
end
function s.redirectTg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS):FilterCount(s.filter,nil,tp),nil) end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	local g=tg:Filter(s.filter,nil,tp)
	local g2=(tg-g):KeepAlive()
	e:SetLabelObject(g2)
	g2:ForEach(function(c) c:CreateEffectRelation(e) end)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,#g,#g,nil)
end
function s.redirectOp(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	local g=e:GetLabelObject():Filter(Card.IsRelateToEffect,nil,e)
	Duel.ChangeTargetCard(ev+(e:IsHasType(EFFECT_TYPE_ACTIVATE) and 1 or 0),tg+g)
end