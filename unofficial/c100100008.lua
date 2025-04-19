--Ｓｐ－ミラクルシンクロフュージョン
--Speed Spell - Miracle Synchro Fusion
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff({handler=c,fusfilter=function(c) return c.miracle_synchro_fusion end,matfilter=Fusion.OnFieldMat(Card.IsAbleToRemove),extrafil=s.fextra,extraop=Fusion.BanishMaterial,desc=aux.Stringid(id,0),extratg=s.extratg})
	e1:SetCost(s.cost)
	c:RegisterEffect(e1)
	--Draw
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(s.drcon)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
	if chk==0 then return tc and tc:IsCanRemoveCounter(tp,0x91,2,REASON_COST) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	tc:RemoveCounter(tp,0x91,2,REASON_COST)
end
function s.fcheck(tp,sg,fc)
	return sg:IsExists(aux.FilterBoolFunction(Card.IsType,TYPE_SYNCHRO,fc,SUMMON_TYPE_FUSION,tp),1,nil)
end
function s.fextra(e,tp,mg)
	if not Duel.IsPlayerAffectedByEffect(tp,69832741) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_GRAVE,0,nil),s.fcheck
	end
	return nil,s.fcheck
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_ONFIELD|LOCATION_GRAVE)
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (r&(REASON_EFFECT+REASON_DESTROY))==(REASON_EFFECT+REASON_DESTROY) and rp==1-tp and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end