--転生炎獣の炎陣
--Salamangreat Circle
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
	--recarnation check
	aux.GlobalCheck(s,function()
		local e1=Effect.GlobalEffect()
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_MATERIAL_CHECK)
		e1:SetValue(s.val)
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
		ge1:SetLabelObject(e1)
		ge1:SetTargetRange(0xff,0xff)
		ge1:SetTarget(s.gtg)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_series={0x119}
function s.gtg(e,c)
	return c:IsLinkMonster() and c:IsSetCard(0x119)
end
function s.val(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsSummonCode,1,nil,c,SUMMON_TYPE_LINK,c:GetControler(),c:GetCode()) and c:IsSummonType(SUMMON_TYPE_LINK) then
		c:RegisterFlagEffect(41463181,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD-RESET_LEAVE-RESET_TEMP_REMOVE,0,1)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.immfilter(chkc) end
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	local b2=Duel.IsExistingTarget(s.immfilter,tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	elseif b1 then
		op=Duel.SelectOption(tp,aux.Stringid(id,0))
	else
		op=Duel.SelectOption(tp,aux.Stringid(id,1))+1
	end
	if op==0 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e:SetProperty(0)
		e:SetOperation(s.thop)
	else
		e:SetCategory(0)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e:SetOperation(s.immop)
		Duel.SelectTarget(tp,s.immfilter,tp,LOCATION_MZONE,0,1,1,nil)
	end
end
function s.thfilter(c)
	return c:IsSetCard(0x119) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.immfilter(c)
	return c:IsLinkMonster() and c:IsSetCard(0x119) and c:GetFlagEffect(41463181)~=0
end
function s.immop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
		e3:SetRange(LOCATION_MZONE)
		e3:SetCode(EFFECT_IMMUNE_EFFECT)
		e3:SetDescription(aux.Stringid(id,2))
		e3:SetValue(s.efilter)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
	end
end
function s.efilter(e,te)
	return te:IsActiveType(TYPE_MONSTER) and te:GetOwner()~=e:GetOwner()
end

