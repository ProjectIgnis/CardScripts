--CX 冀望皇バリアン
--CXyz Barian Hope
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 3+ Level 7 monsters OR 1 "Number C101" through "Number C107"
	Xyz.AddProcedure(c,nil,7,3,s.ovfilter,aux.Stringid(id,0),Xyz.InfiniteMats)
	--Gains 1000 ATK for each Xyz material it has
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	--Change this card's name and effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.copytg)
	e2:SetOperation(s.copyop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_NUMBER}
function s.ovfilter(c,tp,lc)
	local class=c:GetMetatable(true)
	if class==nil then return false end
	local no=class.xyz_number
	return c:IsFaceup() and no and no>=101 and no<=107 and c:IsSetCard(SET_NUMBER_C,lc,SUMMON_TYPE_XYZ,tp)
end
function s.atkval(e,c)
	return c:GetOverlayCount()*1000
end
function s.filter(c)
	return c:IsSetCard(SET_NUMBER) and c:IsType(TYPE_EFFECT)
end
function s.copytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil)
end
function s.copyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) then
		local code=tc:GetOriginalCode()
		--This card's name becomes the target's name
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(code)
		e1:SetLabel(tp)
		e1:SetReset(RESETS_STANDARD_PHASE_END|RESET_OPPO_TURN)
		c:RegisterEffect(e1)
		--Replace this card's effect with that monster's original effect
		local cid=c:CopyEffect(code,RESETS_STANDARD_PHASE_END|RESET_OPPO_TURN)
		--Reset the effects manually at the End Phase of the opponent's next turn
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,2))
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCountLimit(1)
		e2:SetRange(LOCATION_MZONE)
		e2:SetCondition(s.resetcon)
		e2:SetOperation(s.resettop)
		e2:SetLabel(cid)
		e2:SetLabelObject(e1)
		e2:SetReset(RESETS_STANDARD_PHASE_END|RESET_OPPO_TURN)
		c:RegisterEffect(e2)
	end
end
function s.resetcon(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetLabelObject():GetLabel()
	return Duel.IsTurnPlayer(1-p)
end
function s.resettop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cid=e:GetLabel()
	c:ResetEffect(cid,RESET_COPY)
	c:ResetEffect(RESET_DISABLE,RESET_EVENT)
	local e1=e:GetLabelObject()
	e1:Reset()
	Duel.HintSelection(Group.FromCards(c))
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
