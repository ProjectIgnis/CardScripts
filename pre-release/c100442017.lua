--クッキィ☆ヤミー
--Cooky☆Yummy
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--If you control a Link-1 monster or a Level 2 Synchro Monster, you can Special Summon this card (from your hand)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	--Make 1 opponent's face-up monster lose 1000 ATK, or, if this card was Special Summoned by a Synchro Monster's effect, you can destroy that monster instead
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
s.listed_series={SET_YUMMY}
function s.spconfilter(c)
	return (c:IsLink(1) or (c:IsType(TYPE_SYNCHRO) and c:IsLevel(2))) and c:IsFaceup()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spconfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local sp_chk=re and e:GetHandler():IsSpecialSummoned() and re:IsMonsterEffect() and re:GetHandler():IsOriginalType(TYPE_SYNCHRO)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	e:SetLabel(sp_chk and 1 or 0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
	if sp_chk then
		Duel.SetPossibleOperationInfo(0,CATEGORY_ATKCHANGE,tc,1,tp,-1000)
		Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,tc,1,tp,0)
	else
		Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,tc,1,tp,-1000)
	end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local sp_chk=e:GetLabel()==1
	local b1=tc:IsFaceup()
	local b2=sp_chk
	if not (b1 or b2) then return end
	local op=nil
	if sp_chk then
		op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,2)},
			{b2,aux.Stringid(id,3)})
	else
		op=1
	end
	if op==1 then
		--It loses 1000 ATK
		tc:UpdateAttack(-1000,nil,e:GetHandler())
	elseif op==2 then
		--Destroy it
		Duel.Destroy(tc,REASON_EFFECT)
	end
end