--特許権の契約書類
--Dark Contract with Patent License
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Inflict 1000 Damage to the opponent and prevent Special Summons
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CUSTOM+id)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTarget(s.damtg)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
	local g=Group.CreateGroup()
	g:KeepAlive()
	e2:SetLabelObject(g)
	--Keep track of the summoned monsters
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetLabelObject(e2)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)
	--Add 1 "D/D" monster to the hand
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_DDD,SET_DD}
function s.damcfilter(c,tp)
	local ty=c:GetType()&(TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK)
	return c:IsSummonPlayer(1-tp) and ty~=0 and Duel.IsExistingMatchingCard(s.damcfilter2,tp,LOCATION_MZONE,0,1,nil,ty)
end
function s.damcfilter2(c,ty)
	return c:IsFaceup() and c:IsSetCard(SET_DDD) and c:IsType(ty)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local tg=eg:Filter(s.damcfilter,nil,tp)
	if #tg>0 then
		for tc in tg:Iter() do
			tc:RegisterFlagEffect(id,RESET_CHAIN,0,1)
		end
		local g=e:GetLabelObject():GetLabelObject()
		if Duel.GetCurrentChain()==0 then g:Clear() end
		g:Merge(tg)
		g:Remove(function(c) return c:GetFlagEffect(id)==0 end,nil)
		e:GetLabelObject():SetLabelObject(g)
		Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+id,e,0,tp,tp,0)
	end
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetLabelObject()
	if chk==0 then return #g>0 and Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(1000)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
	local ty=0
	local g=e:GetLabelObject()
	for tc in aux.Next(g) do
		ty=ty | tc:GetType()
	end
	ty=ty & (TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK)
	--Cannot Special Summon monsters of the same type
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(0,1)
	e1:SetTarget(s.sumlimit)
	e1:SetLabel(ty)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	c:RegisterEffect(e1)
end
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	local typ=e:GetLabel()
	if c:IsMonster() then
		return c:IsType(typ)
	else
		return c:IsOriginalType(typ)
	end
end
function s.thfilter(c)
	return c:IsMonster() and c:IsSetCard(SET_DD) and (c:IsFaceup() or not c:IsLocation(LOCATION_EXTRA)) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_EXTRA|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA|LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_EXTRA|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end