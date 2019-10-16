--剛鬼ザ・ソリッド・オーガ
--Gouki The Solid Ogre
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0xfc),2)
	c:EnableReviveLimit()
	--indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetCondition(s.incon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
	--move
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.seqtg)
	e3:SetOperation(s.seqop)
	c:RegisterEffect(e3)
end
s.listed_series={0xfc}
s.listed_names={22510667}
function s.incon(e)
	return e:GetHandler():GetLinkedGroupCount()>0 
	and e:GetHandler():GetLinkedGroup():IsExists(aux.FilterFaceupFunction(Card.IsSetCard,0xfc),1,nil)
end
function s.seqfilter(c,zone)
	return c:IsFaceup() and c:IsSetCard(0xfc) and not c:IsCode(id)
		and c:GetSequence()<5 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE,c:GetControler(),LOCATION_REASON_CONTROL,zone)>0
end
function s.seqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local zone=c:GetLinkedZone(tp)&0x1f
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.seqfilter(chkc,zone) end
	if chk==0 then return Duel.IsExistingTarget(s.seqfilter,tp,LOCATION_MZONE,0,1,nil,zone) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.seqfilter,tp,LOCATION_MZONE,0,1,1,nil,zone)
end
function s.seqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=c:GetLinkedZone(tp)&0x1f
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) or Duel.GetLocationCount(tc:GetControler(),LOCATION_MZONE,tc:GetControler(),LOCATION_REASON_CONTROL,zone)<=0 then return end
	local i=0
	if not c:IsControler(tp) then i=16 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	local nseq=math.log(Duel.SelectDisableField(tp,1,LOCATION_MZONE,LOCATION_MZONE,~(zone<<i)),2)-i
	Duel.MoveSequence(tc,nseq)
end

