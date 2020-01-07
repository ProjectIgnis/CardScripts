--寝ガエル
--Othello Frog
local s,id=GetID()
function s.initial_effect(c)
	--cannot material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	c:RegisterEffect(e3)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	c:RegisterEffect(e4)
	--to defense
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_POSITION)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_SUMMON_SUCCESS)
	e5:SetTarget(s.postg)
	e5:SetOperation(s.posop)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e6)
	--control
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,1))
	e7:SetCategory(CATEGORY_CONTROL)
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCountLimit(1)
	e7:SetTarget(s.cttg)
	e7:SetOperation(s.ctop)
	c:RegisterEffect(e7)
end
s.listed_names={id}
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttackPos() and c:IsRelateToEffect(e) then
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
function s.ctfilter1(c,tp)
	local seq=c:GetSequence()
	if seq>4 then return false end
	return (seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1))
		or (seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1))
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.ctfilter1(chkc,1-tp) end
	if chk==0 then return Duel.IsExistingTarget(s.ctfilter1,tp,0,LOCATION_MZONE,1,nil,1-tp)
		and e:GetHandler():IsControlerCanBeChanged() end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,s.ctfilter1,tp,0,LOCATION_MZONE,1,1,nil,1-tp)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,e:GetHandler(),1,0,0)
end
function s.ctfilter2(c)
	return c:GetSequence()<5 and c:IsFaceup() and c:IsCode(id)
end
function s.ctfilter3(c,seq1,seq2)
	local seq=c:GetSequence()
	return seq>seq1 and seq<seq2 and c:IsControlerCanBeChanged()
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsControler(1-tp) or not c:IsPosition(POS_FACEUP_DEFENSE) then return end
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsControler(tp) then return end
	local seq=tc:GetSequence()
	if seq>4 then return end
	local zone=0
	if seq>0 then zone=bit.replace(zone,0x1,seq-1) end
	if seq<4 then zone=bit.replace(zone,0x1,seq+1) end
	if Duel.GetControl(c,1-tp,0,0,zone)==0 then return end
	local g1=Duel.GetMatchingGroup(s.ctfilter2,tp,0,LOCATION_MZONE,nil)
	if #g1==2 then
		local seq1=g1:GetFirst():GetSequence()
		local seq2=g1:GetNext():GetSequence()
		if seq2<seq1 then seq1,seq2=seq2,seq1 end
		local g2=Duel.GetMatchingGroup(s.ctfilter3,tp,0,LOCATION_MZONE,nil,seq1,seq2)
		if #g2>0 then
			Duel.BreakEffect()
			Duel.GetControl(g2,tp)
		end
	end
end

