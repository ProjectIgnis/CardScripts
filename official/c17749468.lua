--贖罪神女
--Azamina
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: 1 "Queen Azamina" + 1 Fusion or Synchro Monster
	Fusion.AddProcMix(c,true,true,65033975,aux.FilterBoolFunctionEx(Card.IsType,TYPE_FUSION|TYPE_SYNCHRO))
	c:AddMustFirstBeFusionSummoned()
	--Special Summon this card (from your Extra Deck) by Tributing 1 "Saint Azamina" you control and 1 face-up monster your opponent controls
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetCondition(s.selfspcon)
	e0:SetTarget(s.selfsptg)
	e0:SetOperation(s.selfspop)
	c:RegisterEffect(e0)
	--Cannot be destroyed by card effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Each time your opponent activates a card or effect, all monsters your opponent currently controls lose 500 ATK immediately after it resolves
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2a:SetCode(EVENT_CHAINING)
	e2a:SetRange(LOCATION_MZONE)
	e2a:SetOperation(aux.chainreg)
	c:RegisterEffect(e2a)
	local e2b=Effect.CreateEffect(c)
	e2b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2b:SetProperty(EFFECT_FLAG_DELAY)
	e2b:SetCode(EVENT_CHAIN_SOLVED)
	e2b:SetRange(LOCATION_MZONE)
	e2b:SetCondition(function(e) return e:GetHandler():HasFlagEffect(1) end)
	e2b:SetOperation(s.atkop)
	c:RegisterEffect(e2b)
	--Your opponent cannot activate the effects of monsters with 0 ATK
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetValue(function(e,re,tp) return re:IsMonsterEffect() and re:GetHandler():IsAttack(0) end)
	c:RegisterEffect(e3)
end
s.miracle_synchro_fusion=true
s.material_setcode={SET_AZAMINA}
s.listed_names={65033975,85065943} --"Queen Azamina", "Saint Azamina"
function s.selfspcostfilter(c,tp,fc)
	return ((c:IsCode(85065943) or c:IsSummonCode(fc,MATERIAL_FUSION,tp,85065943)) or c:IsControler(1-tp)) and c:IsReleasable()
		and c:IsCanBeFusionMaterial(fc,MATERIAL_FUSION) and (c:IsControler(tp) or c:IsFaceup())
end
function s.rescon(sg,e,tp,mg)
	return Duel.GetLocationCountFromEx(tp,tp,sg,e:GetHandler())>0
		and sg:FilterCount(Card.IsControler,nil,tp)==1
end
function s.selfspcon(e,c)
	if not c then return true end
	local tp=c:GetControler()
	local mg=Duel.GetMatchingGroup(s.selfspcostfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp,e:GetHandler())
	return #mg>=2 and aux.SelectUnselectGroup(mg,e,tp,2,2,s.rescon,0)
end
function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local mg=Duel.GetMatchingGroup(s.selfspcostfilter,tp,LOCATION_ONFIELD,LOCATION_MZONE,nil,tp,e:GetHandler())
	local g=aux.SelectUnselectGroup(mg,e,tp,2,2,s.rescon,1,tp,HINTMSG_RELEASE,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.selfspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Release(g,REASON_COST|REASON_MATERIAL)
	g:DeleteGroup()
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	if rp~=1-tp then return end
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if #g==0 then return end
	Duel.Hint(HINT_CARD,0,id)
	local c=e:GetHandler()
	for tc in g:Iter() do
		--It loses 500 ATK
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-500)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end