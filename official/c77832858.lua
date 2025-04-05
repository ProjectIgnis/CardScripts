--邪炎帝王テスタロス
--Thestalos the Shadowfire Monarch
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Tribute Summon by Tributing 1 monster the opponent controls and 1 Tribute Summoned monster you control
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(s.sumcon)
	e1:SetTarget(s.sumtg)
	e1:SetOperation(s.sumop)
	e1:SetValue(SUMMON_TYPE_TRIBUTE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e2)
	--Banish 1 random card from the opponent's hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCondition(function(e) return e:GetHandler():IsTributeSummoned() end)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_MATERIAL_CHECK)
	e4:SetValue(s.valcheck)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
end
function s.cfilter(c,relzone,tp)
	return aux.IsZone(c,relzone,tp) and c:IsReleasable() and (c:IsTributeSummoned() or c:IsControler(1-tp))
end
function s.rescon(soul_ex_g,zone)
	return	function(sg,e,tp,mg)
				return (#soul_ex_g==0 or sg&soul_ex_g==soul_ex_g) and Duel.GetMZoneCount(tp,sg,tp,LOCATION_REASON_TOFIELD,zone)>0
					and sg:FilterCount(Card.IsControler,nil,tp)==1
			end
end
function s.sumcon(e,c,minc,zone,relzone,exeff)
	if c==nil then return true end
	if minc>2 or c:IsLevelBelow(6) then return false end
	local tp=c:GetControler()
	local mg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,relzone,tp)
	local soul_ex_g=Duel.GetMatchingGroup(Card.IsHasEffect,tp,LOCATION_MZONE,LOCATION_MZONE,nil,EFFECT_EXTRA_RELEASE)
	return #mg>=2 and aux.SelectUnselectGroup(mg,e,tp,2,2,s.rescon(soul_ex_g,zone),0)
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk,c,minc,zone,relzone,exeff)
	local mg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,relzone,tp)
	local soul_ex_g=Duel.GetMatchingGroup(Card.IsHasEffect,tp,LOCATION_MZONE,LOCATION_MZONE,nil,EFFECT_EXTRA_RELEASE)
	local g=aux.SelectUnselectGroup(mg,e,tp,2,2,s.rescon(soul_ex_g,zone),1,tp,HINTMSG_RELEASE,nil,nil,true)
	if g and #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp,c,minc,zone,relzone,exeff)
	local g=e:GetLabelObject()
	c:SetMaterial(g)
	Duel.Release(g,REASON_SUMMON|REASON_MATERIAL)
	g:DeleteGroup()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
	if e:GetLabel()==1 then
		e:SetLabel(0)
		Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,PLAYER_ALL,LOCATION_ONFIELD)
		Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
	end
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil)
	if #g==0 then return end
	local rg=g:RandomSelect(tp,1)
	if #rg>0 and Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)>0 and Duel.Damage(1-tp,1000,REASON_EFFECT)>0
		and Duel.GetPossibleOperationInfo(0,CATEGORY_REMOVE)
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local rc=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil):GetFirst()
		if rc and Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)>0 and rc:IsAttribute(ATTRIBUTE_FIRE|ATTRIBUTE_DARK) and rc:HasLevel() then
			Duel.BreakEffect()
			Duel.Damage(1-tp,rc:GetLevel()*200,REASON_EFFECT)
		end
	end
end
function s.valfilter(c)
	return c:IsLevelAbove(8) and c:IsTributeSummoned()
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(s.valfilter,1,nil) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end